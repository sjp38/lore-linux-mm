Return-Path: <SRS0=TNGr=QM=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.9 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 1DC7DC282D7
	for <linux-mm@archiver.kernel.org>; Tue,  5 Feb 2019 09:03:52 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id B3B3A2075B
	for <linux-mm@archiver.kernel.org>; Tue,  5 Feb 2019 09:03:51 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="M7TCpRGF"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org B3B3A2075B
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 130C78E007C; Tue,  5 Feb 2019 04:03:51 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 0ED6F8E001C; Tue,  5 Feb 2019 04:03:51 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id EE98F8E007C; Tue,  5 Feb 2019 04:03:50 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-yb1-f197.google.com (mail-yb1-f197.google.com [209.85.219.197])
	by kanga.kvack.org (Postfix) with ESMTP id C41F18E001C
	for <linux-mm@kvack.org>; Tue,  5 Feb 2019 04:03:50 -0500 (EST)
Received: by mail-yb1-f197.google.com with SMTP id y3so1072134ybf.12
        for <linux-mm@kvack.org>; Tue, 05 Feb 2019 01:03:50 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:subject:from
         :in-reply-to:date:cc:content-transfer-encoding:message-id:references
         :to;
        bh=iiLzaNANibauf4WDgP9oQJ7qsEJ7GeQ8Co2yEFUHTIY=;
        b=Ij/R+QC5x9sljfPcjYSBfW9G5VpWIjZSv6Omc+hbldg4l3FeYcZbQW1fus55x8nW1x
         Vhsl+9ZtKLtfrNVwYMowqtHZWQvSVt1WcIrSQZHgVHVNvREsK8N7jY2DOuFeVRlpTGqq
         LrzU3KEAyVkrFvQJw2ou1uaa4B03pSWkmJN13q4ZZ2EVNXEKU/gvMtk6Kf7WtPNFaI2h
         8zkHXvuO1P+iUpceCDCBxtqih5C0eTOwZ3g3Ot7KEogpxAMBJENqMG5rs5ogI8D4E5nB
         efz71il8Uv1Vb5LX1zD1RK9FoS7omXktDdUUrupdJUITDrKE2j6ayqF2XfkVJPDM+5gC
         FCNg==
X-Gm-Message-State: AHQUAubMpDvE0VL6vDrx9WfHR2MXkFuzMYdoyYsiqgTZWzYVTy8tyo8p
	AYXbEjTQ3t5TvD2tCHXdiEY7gi8cjk2A1tAs134V/HqUsBSGWlfLvuVavQs3c3aenccgcxmwRBK
	qxfuwaGe8IdNM/4q3o9keOgrSFrO1h2yXlkghmjWi35kKjtIeGtZShMvkiQF22pso3HCA5Z7fjZ
	1E8eLQVzVmBPiiOya8zNad+UCJbf7o5da+WwF2t98rE4hlbqFy97dLV1GLknlkzrCWbZ8FQVby/
	GQoCm/tf/H8SZPjzuKIXDDzafsfCcs/DtF+liHZXfbowmwke9Ti00X9rgU0FcWXcqKHwB/iTdLA
	nEq4u/n47QpTryusE4r4TwBQ3sqrOLKsMVRM5l5aY/ENaKTu2mpOMpJ+KlYA2WTZN1uG9D4dRIu
	N
X-Received: by 2002:a25:4506:: with SMTP id s6mr2869679yba.387.1549357430521;
        Tue, 05 Feb 2019 01:03:50 -0800 (PST)
X-Received: by 2002:a25:4506:: with SMTP id s6mr2869647yba.387.1549357430014;
        Tue, 05 Feb 2019 01:03:50 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1549357430; cv=none;
        d=google.com; s=arc-20160816;
        b=zc1A3WME4/aCIJquGhEWC2EUmqg3e8eP6pvMvbarMcUMe1f6d1ujcRpjNBjR9r0Rk7
         rc/4eibpn9gUv8iN5fnCnPCQlc6mIFbfUOEfxBRjeezUrq87I+/SGvPHWO9hYkPTsWc9
         xl16nfKr3/CPGpoQmMMJtCS7FydksMsZb7qaxbi0Qs0CAQYS67P5ydCx4Xmm5I95dEgD
         SHrrC8eRKLWJK+JxtPnFdBhKzkjK10sY1FEyLyrWgHhpiAyUbbpLh4nVx35j/YRifZRR
         IJ0D3HDDVj1of9UMv3h97dqwQEzaP7LAZee+Us/RU6tZelsyy0TnX6osPTxxEd4ZfFF9
         pJ/w==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=to:references:message-id:content-transfer-encoding:cc:date
         :in-reply-to:from:subject:mime-version:dkim-signature;
        bh=iiLzaNANibauf4WDgP9oQJ7qsEJ7GeQ8Co2yEFUHTIY=;
        b=VETph3hU+sWpqttIFThbWMTgbKQ8OahQcVijpC80+ga/oM+5RtrWkcXa4kQwbzDQb6
         bveNhzDqoioYUb4lZUudtEnJvEWcF5DVT5GR0MAEtWuuqUVzwoKLGlg+8HtCq3FM5QTi
         3hI0HZ5yOjWoXIAU3mBI5A1qx2/tEv8nJX8VbHAmvhW4dWRu0LfmAaVDQqg/7kufk9V+
         78H0XHRbms3XN8TJWNhQNlPwITmWCGpeQ2DmHZcTAiYCehmFP46BqWQVst6a2fzGEY+L
         s6y8AGAYdQobjns7izp3c6ULpW1ebw/Cr3RwOjJh4uheV3zWVCzcTnHLmCqfFgrEn4Qo
         /VFQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=M7TCpRGF;
       spf=pass (google.com: domain of nadav.amit@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=nadav.amit@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id r65sor473590ywf.199.2019.02.05.01.03.49
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 05 Feb 2019 01:03:50 -0800 (PST)
Received-SPF: pass (google.com: domain of nadav.amit@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=M7TCpRGF;
       spf=pass (google.com: domain of nadav.amit@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=nadav.amit@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=mime-version:subject:from:in-reply-to:date:cc
         :content-transfer-encoding:message-id:references:to;
        bh=iiLzaNANibauf4WDgP9oQJ7qsEJ7GeQ8Co2yEFUHTIY=;
        b=M7TCpRGFwBPB1IAhENhKs1QF/a46qPSjmqeRs3zKzekzh4em/YGC8RsQGRf/UyJKhY
         M94T3ExmxV8td1HycDiMeIYWJATjymIjspEGi36ns4QHwEVT1ByPbgTpZHEozl/kDshd
         z9/0F32EdKPdrmk21msVPKSr51OP7upVQ/He+j0aepxVNFGGPBFOQa18TFhD7pi9x+2w
         sb4i6d2T27RRBgBih0cxgcGruO4O2fegbHI1XGGWJt2nY79W/26GUrrE5In0FtHtLbP5
         poZZ5brFGjXxsTiqb+hwwNvtkfwQ/1E/9dGP3+pnftHhkB1+i/joqbXE1xn6/zVPODEG
         Mm9g==
X-Google-Smtp-Source: AHgI3IYEVOw5QrKXj8H8lemNUvI0jmUElJMn+NPfl6e6MupMXqPWylkV9RxkZ0L0f9/SikFyHUah9w==
X-Received: by 2002:a81:2514:: with SMTP id l20mr3002708ywl.3.1549357429310;
        Tue, 05 Feb 2019 01:03:49 -0800 (PST)
Received: from [10.33.115.182] ([66.170.99.1])
        by smtp.gmail.com with ESMTPSA id e9sm1047040ywb.45.2019.02.05.01.03.46
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 05 Feb 2019 01:03:48 -0800 (PST)
Content-Type: text/plain;
	charset=us-ascii
Mime-Version: 1.0 (Mac OS X Mail 12.2 \(3445.102.3\))
Subject: Re: [PATCH v2 04/20] fork: provide a function for copying init_mm
From: Nadav Amit <nadav.amit@gmail.com>
In-Reply-To: <20190205085311.GH21801@zn.tnic>
Date: Tue, 5 Feb 2019 01:03:45 -0800
Cc: Rick Edgecombe <rick.p.edgecombe@intel.com>,
 Andy Lutomirski <luto@kernel.org>,
 Ingo Molnar <mingo@redhat.com>,
 LKML <linux-kernel@vger.kernel.org>,
 X86 ML <x86@kernel.org>,
 "H. Peter Anvin" <hpa@zytor.com>,
 Thomas Gleixner <tglx@linutronix.de>,
 Dave Hansen <dave.hansen@linux.intel.com>,
 Peter Zijlstra <peterz@infradead.org>,
 Damian Tometzki <linux_dti@icloud.com>,
 linux-integrity <linux-integrity@vger.kernel.org>,
 LSM List <linux-security-module@vger.kernel.org>,
 Andrew Morton <akpm@linux-foundation.org>,
 Kernel Hardening <kernel-hardening@lists.openwall.com>,
 Linux-MM <linux-mm@kvack.org>,
 Will Deacon <will.deacon@arm.com>,
 Ard Biesheuvel <ard.biesheuvel@linaro.org>,
 Kristen Carlson Accardi <kristen@linux.intel.com>,
 "Dock, Deneen T" <deneen.t.dock@intel.com>,
 Kees Cook <keescook@chromium.org>,
 Dave Hansen <dave.hansen@intel.com>
Content-Transfer-Encoding: 7bit
Message-Id: <BF9D1501-5EFF-46FB-8DAB-8C7A2088DB42@gmail.com>
References: <20190129003422.9328-1-rick.p.edgecombe@intel.com>
 <20190129003422.9328-5-rick.p.edgecombe@intel.com>
 <20190205085311.GH21801@zn.tnic>
To: Borislav Petkov <bp@alien8.de>
X-Mailer: Apple Mail (2.3445.102.3)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

> On Feb 5, 2019, at 12:53 AM, Borislav Petkov <bp@alien8.de> wrote:
> 
> On Mon, Jan 28, 2019 at 04:34:06PM -0800, Rick Edgecombe wrote:
>> From: Nadav Amit <namit@vmware.com>
>> 
>> - * Allocate a new mm structure and copy contents from the
>> - * mm structure of the passed in task structure.
>> +/**
>> + * dup_mm() - duplicates an existing mm structure
>> + * @tsk: the task_struct with which the new mm will be associated.
>> + * @oldmm: the mm to duplicate.
>> + *
>> + * Allocates a new mm structure and copy contents from the provided
> 
> s/copy/copies/

Thanks, applied (I revised this sentence a bit).

