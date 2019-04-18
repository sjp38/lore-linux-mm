Return-Path: <SRS0=2ZuM=SU=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 6080CC282DD
	for <linux-mm@archiver.kernel.org>; Thu, 18 Apr 2019 21:50:29 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 158AE21479
	for <linux-mm@archiver.kernel.org>; Thu, 18 Apr 2019 21:50:29 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 158AE21479
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=goodmis.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id BCE386B0005; Thu, 18 Apr 2019 17:50:28 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id B55036B0006; Thu, 18 Apr 2019 17:50:28 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 9F71A6B000A; Thu, 18 Apr 2019 17:50:28 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f198.google.com (mail-pg1-f198.google.com [209.85.215.198])
	by kanga.kvack.org (Postfix) with ESMTP id 61A956B0005
	for <linux-mm@kvack.org>; Thu, 18 Apr 2019 17:50:28 -0400 (EDT)
Received: by mail-pg1-f198.google.com with SMTP id j184so2110553pgd.7
        for <linux-mm@kvack.org>; Thu, 18 Apr 2019 14:50:28 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=vLoRlZq906rOX3TkhFi9Ykq+QRtvYofG65eeu8G2ABE=;
        b=o4A0gVjmCXlU+SlLVBwEw3+Qr6W2lLwlWp1HJpEyL/uLBoG05qNSXO/c3F1gIEQD5S
         23/KA7SQvxHjIW9g7ctmV2eF8BQse4I0mnczSaUh46SJP6rA/YTQIRZvru9srC13Qy/j
         V8zb6ecHbtMjuxnBchWKOubDwVL42UN9Y1ktFWsCIrKCR7JWdsUzi4U+VObbTCRdYbbC
         b6vf3cIC02ELZH/gNuRuCeFIObSfkIrh0WIdWPVTyn4mVp1Wuc2Be0iuIYLGGUP8Eavz
         SDtRv23z1DignE3NddVBqTen1nJWqvOT7VAi5RySh7UBqiUNW2n5ttkFjGGfc7SLzs7Z
         mBJQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of srs0=+lpg=su=goodmis.org=rostedt@kernel.org designates 198.145.29.99 as permitted sender) smtp.mailfrom="SRS0=+LPG=SU=goodmis.org=rostedt@kernel.org"
X-Gm-Message-State: APjAAAVxTEWAtWbFnyv21yVTEcgQvMds/3KsEy4bIzGLI5NheIBoJf2/
	EjTHI38Cr4ojmnOebB95+bpZ1Rb4q/0A8WQOeN6PjqAnW/iqSmwoxYqE6IMdHLYmAvSRWW4koBH
	sgkDZE0KtbzYIEnR2TnGj1Xl6gIEexpWZugLFj8Gv17KJBmNBBQl5Yh+wAYceuHc=
X-Received: by 2002:a63:700f:: with SMTP id l15mr256313pgc.3.1555624228055;
        Thu, 18 Apr 2019 14:50:28 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwsaGDryOR4QKqE9j+RwisoM+nucTsh0z9vAhikhyRVHxMYNIl81NfM9KXIsQmmk+tOss/P
X-Received: by 2002:a63:700f:: with SMTP id l15mr256279pgc.3.1555624227399;
        Thu, 18 Apr 2019 14:50:27 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1555624227; cv=none;
        d=google.com; s=arc-20160816;
        b=0ZRbuxw5AxnTe0BFdnUFet2VttRy8Rj+U1TEhPM0DXF0I5N3dX79g716U4yKFgQG3/
         PdenRZ7v477B8j97sQsq8nsTg+Nm+YcjruFKBBLxmjIvmMOUDT2HCZWUZuAP3zbYS7Mt
         OluCtiizkhEorUrH+OIEF98+b5P8XWzAS68SVZ5j7/o8nlxEMtabePVFS6XZ5hX57TPR
         O244LDpvJIj3zePMHdCr1OInhLDarJRTiYVCtwfFR+Gj+8Mf20uh70kmkcEWfcnwXTs9
         WuxcQmL/L6wWkAUREu3tbPGMMIPDCms4K1SApM5LAeqz9hGbkjnG0kSBZhhvpAeIRHwV
         cnGw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:subject:cc:to:from:date;
        bh=vLoRlZq906rOX3TkhFi9Ykq+QRtvYofG65eeu8G2ABE=;
        b=R1BQ7BjJz6xXarpJl4J+ciuNjINtgUibMe62lS1Kooa9KOzsfEhvH8fFxduTP78A0a
         FmyJ4YhySil9+wfBxtiiwUbzNiYxP4lzwBIlvLyRgk6L/g8Ao5Sqltuglo/8HTWhLoBw
         gLYTEBW1gpVVjvNJ4S/I18g90FkasNDNpUmCXp8Le/2vRKNJpLbJG/lUkFhWWs93iUXn
         56cjCkG4smKVxSuqP1xSiL8c12z98fF6ZsZlWGGnb5lVusmSboVv8kEvaifRJxuXy4vJ
         57/Y0MUNmLstiWhQGVtPplmnAzEGpdY6XTTXm5jEJ7DJKILrvPzDalLHz1t0M+8pp+kt
         oUXg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of srs0=+lpg=su=goodmis.org=rostedt@kernel.org designates 198.145.29.99 as permitted sender) smtp.mailfrom="SRS0=+LPG=SU=goodmis.org=rostedt@kernel.org"
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id ci5si3468093plb.145.2019.04.18.14.50.27
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 18 Apr 2019 14:50:27 -0700 (PDT)
Received-SPF: pass (google.com: domain of srs0=+lpg=su=goodmis.org=rostedt@kernel.org designates 198.145.29.99 as permitted sender) client-ip=198.145.29.99;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of srs0=+lpg=su=goodmis.org=rostedt@kernel.org designates 198.145.29.99 as permitted sender) smtp.mailfrom="SRS0=+LPG=SU=goodmis.org=rostedt@kernel.org"
Received: from gandalf.local.home (cpe-66-24-58-225.stny.res.rr.com [66.24.58.225])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPSA id C8F7B20693;
	Thu, 18 Apr 2019 21:50:23 +0000 (UTC)
Date: Thu, 18 Apr 2019 17:50:22 -0400
From: Steven Rostedt <rostedt@goodmis.org>
To: Thomas Gleixner <tglx@linutronix.de>
Cc: Josh Poimboeuf <jpoimboe@redhat.com>, LKML
 <linux-kernel@vger.kernel.org>, x86@kernel.org, Andy Lutomirski
 <luto@kernel.org>, Alexander Potapenko <glider@google.com>, Alexey Dobriyan
 <adobriyan@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, Pekka
 Enberg <penberg@kernel.org>, linux-mm@kvack.org, David Rientjes
 <rientjes@google.com>, Christoph Lameter <cl@linux.com>, Catalin Marinas
 <catalin.marinas@arm.com>, Dmitry Vyukov <dvyukov@google.com>, Andrey
 Ryabinin <aryabinin@virtuozzo.com>, kasan-dev@googlegroups.com, Mike
 Rapoport <rppt@linux.vnet.ibm.com>, Akinobu Mita <akinobu.mita@gmail.com>,
 iommu@lists.linux-foundation.org, Robin Murphy <robin.murphy@arm.com>,
 Christoph Hellwig <hch@lst.de>, Marek Szyprowski
 <m.szyprowski@samsung.com>, Johannes Thumshirn <jthumshirn@suse.de>, David
 Sterba <dsterba@suse.com>, Chris Mason <clm@fb.com>, Josef Bacik
 <josef@toxicpanda.com>, linux-btrfs@vger.kernel.org, dm-devel@redhat.com,
 Mike Snitzer <snitzer@redhat.com>, Alasdair Kergon <agk@redhat.com>,
 intel-gfx@lists.freedesktop.org, Joonas Lahtinen
 <joonas.lahtinen@linux.intel.com>, Maarten Lankhorst
 <maarten.lankhorst@linux.intel.com>, dri-devel@lists.freedesktop.org, David
 Airlie <airlied@linux.ie>, Jani Nikula <jani.nikula@linux.intel.com>,
 Daniel Vetter <daniel@ffwll.ch>, Rodrigo Vivi <rodrigo.vivi@intel.com>,
 linux-arch@vger.kernel.org
Subject: Re: [patch V2 01/29] tracing: Cleanup stack trace code
Message-ID: <20190418175022.4e222d07@gandalf.local.home>
In-Reply-To: <20190418172443.30ec83e3@gandalf.local.home>
References: <20190418084119.056416939@linutronix.de>
	<20190418084253.142712304@linutronix.de>
	<20190418135721.5vwd6ngxagrrrrtt@treble>
	<alpine.DEB.2.21.1904182313470.3174@nanos.tec.linutronix.de>
	<20190418172443.30ec83e3@gandalf.local.home>
X-Mailer: Claws Mail 3.17.3 (GTK+ 2.24.32; x86_64-pc-linux-gnu)
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, 18 Apr 2019 17:24:43 -0400
Steven Rostedt <rostedt@goodmis.org> wrote:

> I believe it was for historical leftovers (there was a time it was
> required), and left there for "paranoid" sake. But let me apply the
> patch and see if it is really needed.

I removed the +1 on the max_entries and set SET_TRACE_ENTRIES to 5 (a
bit extreme). Then I ran the stack tracing with KASAN enabled and it
never complained.

As stated, it was there for historical reasons and I felt 500 was way
more than enough and left the buffer there just out of laziness and
paranoia.

Feel free to remove that if you want.

-- Steve

