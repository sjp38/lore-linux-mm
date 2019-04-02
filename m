Return-Path: <SRS0=cFM0=SE=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS,URIBL_BLOCKED autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 5ADE5C4360F
	for <linux-mm@archiver.kernel.org>; Tue,  2 Apr 2019 19:26:45 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 23CD12082C
	for <linux-mm@archiver.kernel.org>; Tue,  2 Apr 2019 19:26:45 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 23CD12082C
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=linux-foundation.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id A48BB6B0273; Tue,  2 Apr 2019 15:26:44 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 9F8B36B0274; Tue,  2 Apr 2019 15:26:44 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 8C0F66B0275; Tue,  2 Apr 2019 15:26:44 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f200.google.com (mail-pf1-f200.google.com [209.85.210.200])
	by kanga.kvack.org (Postfix) with ESMTP id 5680A6B0273
	for <linux-mm@kvack.org>; Tue,  2 Apr 2019 15:26:44 -0400 (EDT)
Received: by mail-pf1-f200.google.com with SMTP id h15so10492754pfj.22
        for <linux-mm@kvack.org>; Tue, 02 Apr 2019 12:26:44 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=Ru63b56YkJYzy/hWEL/aVO+6QHkZEdTGvps5jBMoL+o=;
        b=LWWT8DyWBe/AOnIL0GGPqicrwmhycDlcDhoxHvu4iwZCUileroSZJrH4cljINDbWnN
         +cxEsaCq5des+eCGgaZCl0TzTRhyh5R8Lyx2Y+UALiycUycQoIlemQBWecVdDVTzarw+
         2lKVDDWOyA9zHz/6OLpriAYZQRDd9uS0+5WEE+FjxslRQ+aC3ncXZa9gPsUziwHUazj+
         3tiYuodU7vTHBHYQT/FOL42iygLKOgHqkFAamv0LUDuDgSws4KbfQD6KZNLx7BfdWwyh
         orv+/4o2NlNMHxAkf1jIAEhO6MIyQ9A6376l6b0f6U4q7YjhUBpo3wxQbIYyry8+tpSF
         a8Ow==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of akpm@linux-foundation.org designates 140.211.169.12 as permitted sender) smtp.mailfrom=akpm@linux-foundation.org
X-Gm-Message-State: APjAAAUvHA7/dOfzngTRRVpCggyAQBJLfvXNsgd71o0y7r0KffcFQTYe
	9RTzdrGJMDPPofmF8bUzUFAvZ0fdByiTKmS0hnlR+U03ni1dfU83ElXsIVU8C/Rubdf4mmVgvUN
	X1Li/Ib/CKO1paRA1F8+OBZRl80VAZk+V9jDxLburK5bkuDsRHjRj8fINhnLVaqGXmQ==
X-Received: by 2002:a17:902:ea0d:: with SMTP id cu13mr14693292plb.92.1554233203980;
        Tue, 02 Apr 2019 12:26:43 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxfVpmqihtAE2XU0RYVGS1YhWvVcZd9iW7iRUYYzBYhGMGa1nFV7/F7Y0WnFV83BcIU8urc
X-Received: by 2002:a17:902:ea0d:: with SMTP id cu13mr14693259plb.92.1554233203306;
        Tue, 02 Apr 2019 12:26:43 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1554233203; cv=none;
        d=google.com; s=arc-20160816;
        b=W/kcfI8j4/xTH37Q3kwYrk2WbHnvD9juO1WnJwFrbyC4in4zE/nadVPNsTek1EQsTk
         R2XE4rBizrFHfLuc0QbOZ8/si1GHKFGGWrC3mNgvJoCTJWh2gTqH8cYtlvaJCJIG/Mq8
         WtT0p2EYppsUforGQvx2oAbF7IVSn6rN1HwcuoyJ/KFF8qgEsQvQFpg0+wgnGt/Fs4W/
         e3290Kczdf9mY61zycXXqX9kW1mBbcRKABsXuFFkQlMrp2pfolkItPiEGIO0GYvieg5R
         w2txV+7hFXbAwG7M4Cp4Psqd2zTjPBiLAdWeIJ1yjhwM8fa/OT8O3Yu/jCBWfZ8ci15l
         /9Ug==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:subject:cc:to:from:date;
        bh=Ru63b56YkJYzy/hWEL/aVO+6QHkZEdTGvps5jBMoL+o=;
        b=sE80YFVgpkyslnQcg3PfRcwM72xlQb3+DyMGwLzcaS1zhMG7I+f9rwzB9wNcztdOiE
         vND5KmoWTBrkF6tYKnnSQGMdZpu3G+mAuta1i1doFodLlEzmcRyrDYTBEirsp0WUugjL
         Kc6cx9tEBYch2TcOP9iMzRuOU+7xFi6G4gqafkguzggkuJq5Eaevym0Aqo8FP/ZtTOR5
         JKOSeb7d6MPMZTZTPfYBADnCBYNu5LcmIXAVk/QJel61tno33U/SqjO+Co7REmBPaDm8
         WtxQ0n1VM0wR0eKW2Z8vHiMcsBQ63hpb+y52k0DSDa1L0edAunUlp/hmF0o7gkbJp8su
         SNvQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of akpm@linux-foundation.org designates 140.211.169.12 as permitted sender) smtp.mailfrom=akpm@linux-foundation.org
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id m10si11538912pll.355.2019.04.02.12.26.43
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 02 Apr 2019 12:26:43 -0700 (PDT)
Received-SPF: pass (google.com: domain of akpm@linux-foundation.org designates 140.211.169.12 as permitted sender) client-ip=140.211.169.12;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of akpm@linux-foundation.org designates 140.211.169.12 as permitted sender) smtp.mailfrom=akpm@linux-foundation.org
Received: from akpm3.svl.corp.google.com (unknown [104.133.8.65])
	by mail.linuxfoundation.org (Postfix) with ESMTPSA id 1689CEA2;
	Tue,  2 Apr 2019 19:26:42 +0000 (UTC)
Date: Tue, 2 Apr 2019 12:26:41 -0700
From: Andrew Morton <akpm@linux-foundation.org>
To: "Uladzislau Rezki (Sony)" <urezki@gmail.com>
Cc: Roman Gushchin <guro@fb.com>, Michal Hocko <mhocko@suse.com>, Matthew
 Wilcox <willy@infradead.org>, linux-mm@kvack.org, LKML
 <linux-kernel@vger.kernel.org>, Thomas Garnier <thgarnie@google.com>,
 Oleksiy Avramchenko <oleksiy.avramchenko@sonymobile.com>, Steven Rostedt
 <rostedt@goodmis.org>, Joel Fernandes <joelaf@google.com>, Thomas Gleixner
 <tglx@linutronix.de>, Ingo Molnar <mingo@elte.hu>, Tejun Heo
 <tj@kernel.org>, <rong.a.chen@intel.com>
Subject: Re: [RESEND PATCH 0/3] improve vmap allocation
Message-Id: <20190402122641.d4c8b7cbc6409ad14c13f3aa@linux-foundation.org>
In-Reply-To: <20190402162531.10888-1-urezki@gmail.com>
References: <20190402162531.10888-1-urezki@gmail.com>
X-Mailer: Sylpheed 3.7.0 (GTK+ 2.24.31; x86_64-pc-linux-gnu)
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue,  2 Apr 2019 18:25:28 +0200 "Uladzislau Rezki (Sony)" <urezki@gmail.com> wrote:

> Changes in v3
> -------------
> - simplify the __get_va_next_sibling() and __find_va_links() functions;
> - remove "unlikely". Place the WARN_ON_ONCE directly to the "if" condition;
> - replace inline to __always_inline;
> - move the debug code to separate patches;

Does v3 address the report from kernel test robot
<rong.a.chen@intel.com>, Subject "[mm/vmalloc.c] 7ae76449bd:
kernel_BUG_at_lib/list_debug.c".

For some reason I cannot find that email in my linux-kernel folder and
nor does google find it and
http://lkml.kernel.org/r/20190401132655.GD9217@shao2-debian doesn't
work.  Message-ID 20190401132655.GD9217@shao2-debian doesn't seem to
have got through the list server.  Ditto linux-mm.

