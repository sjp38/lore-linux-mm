Return-Path: <SRS0=Ydgi=QF=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS autolearn=unavailable autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 5FE55C282CD
	for <linux-mm@archiver.kernel.org>; Tue, 29 Jan 2019 01:34:57 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 270132148E
	for <linux-mm@archiver.kernel.org>; Tue, 29 Jan 2019 01:34:57 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 270132148E
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=ellerman.id.au
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id B20A38E0003; Mon, 28 Jan 2019 20:34:56 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id AA9308E0001; Mon, 28 Jan 2019 20:34:56 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 972A08E0003; Mon, 28 Jan 2019 20:34:56 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f199.google.com (mail-pg1-f199.google.com [209.85.215.199])
	by kanga.kvack.org (Postfix) with ESMTP id 521208E0001
	for <linux-mm@kvack.org>; Mon, 28 Jan 2019 20:34:56 -0500 (EST)
Received: by mail-pg1-f199.google.com with SMTP id r13so12752498pgb.7
        for <linux-mm@kvack.org>; Mon, 28 Jan 2019 17:34:56 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:in-reply-to:references:date:message-id:mime-version;
        bh=zu+CkY1kc/8v1pZpdu1YbIBz2fOkHMIcj5De/2BGasE=;
        b=kPYZm58ueJbI/c1Zoy9WkeOOFoRINrOVIcwMEceDekFnCDyy933tgp1DQlh2QgEARS
         Fa/7hZRIQvZ/fuegoAiaIOnfL1lQMe9SWuEV5pvjOzrBxXNCH9x1Un5ly2aTL+oiLxOC
         Yhqa0YSfNvXoqzHXHQv87+QPmBatzTNdLnk4NwI5TVS3DJSHj7sqAplJE/beYEjOcUYo
         aCdj1sRrgnui0Qn9Vdi10RDsFtCCkzDLOqJNlpcSKCpwK4NAWRr9io6xIfF9kBIFrNO/
         Ho900k6cnLP66CyL1+f+0qm33Z4Y6maXQ7Hj4cWbn3BgX1kdr8Lx1jeyhfmHCUwpgDYn
         BhKg==
X-Original-Authentication-Results: mx.google.com;       spf=neutral (google.com: 2401:3900:2:1::2 is neither permitted nor denied by best guess record for domain of mpe@ellerman.id.au) smtp.mailfrom=mpe@ellerman.id.au
X-Gm-Message-State: AJcUukcg1hI9PXmqJdzk23wIGzNGJcV5pNLqdzgAv4F2sgYqEb7IEAhT
	yDsoDFCLLtesTMgEkU/9xtqb8WDd43jHLISXEysfKZjxq2lF5wjrJylzM05AiGvXLflg07kqiiT
	VIfBLemNWYwhA5iEjSgVrokuuFAapM/VYlmyWhTW9AiRnJAAh+lD8K0PaOgdAx+c=
X-Received: by 2002:a17:902:1e9:: with SMTP id b96mr24101439plb.150.1548725696007;
        Mon, 28 Jan 2019 17:34:56 -0800 (PST)
X-Google-Smtp-Source: ALg8bN7z60CAXuy2ALzb8jPU8VEjKisMh7WDt6FX4t+dEuK9WyxAcUfmumBvvd1y7hp2hybD2XC+
X-Received: by 2002:a17:902:1e9:: with SMTP id b96mr24101401plb.150.1548725695321;
        Mon, 28 Jan 2019 17:34:55 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1548725695; cv=none;
        d=google.com; s=arc-20160816;
        b=EDRphZFH8Z3E3563P2QqleC6EKMJ24JmU7KM7wtAo9OBDaLTg0JveltA9fkc7ZyDdi
         CX4pJDx5RV0S2mYn7pD68lFJumPhKGs/pbDpDdWbo90xb7B44XFK7naAwofgOco8sTOB
         mp8LDnG3hrIy+uzSaX1b7AjCdXMVKZU6Kfrb/WYudekefKoULiQ1Ym1eXCo/A/BYYNQB
         O07skAM/bf8GS/rTh+QjexCC1DS9aeDHeGLv9qmixrekgyVZMwLgIW+fWvDBbce+nncv
         /dC1IAXWKXe5bJB0A51IGEC5mSEF3HYO1q42xjjrCDyIkKM4xH9MwaydAEUVLkfl4tCk
         5eoA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:message-id:date:references:in-reply-to:subject:cc:to
         :from;
        bh=zu+CkY1kc/8v1pZpdu1YbIBz2fOkHMIcj5De/2BGasE=;
        b=zYCF6qOeHRzRDs4shE+HzEhzYf6WocR800dK9DcUTKG2yTbVXRSk/oOAclpleZzbjG
         +xXfswcdzapFfW/SenEYa3GZMToVNV9/AbWIHAVHIJFKZiBsYHzDQZf7pHLGRo0IfZSt
         zJRrq8HSbJuN1Q28b5dUKc70/ZW37Ggw7G/s71V7MRy6j1tZVqKjsSG/NZEXRkH5mcK5
         jiqUEvMPRRogDJh85hVt0eAfobvj/5bNc/R09JjQ8w1ju2sU1QW+Gfbe0EYYp7IdjuW8
         r8EgTG11Bv5bdRYx3DN5ekDoruGLeBM2CYUVaywCphdNbqlLBzngAjPXNI5mMC3YQ/fl
         h2QQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=neutral (google.com: 2401:3900:2:1::2 is neither permitted nor denied by best guess record for domain of mpe@ellerman.id.au) smtp.mailfrom=mpe@ellerman.id.au
Received: from ozlabs.org (ozlabs.org. [2401:3900:2:1::2])
        by mx.google.com with ESMTPS id u3si32334323pgj.300.2019.01.28.17.34.54
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Mon, 28 Jan 2019 17:34:55 -0800 (PST)
Received-SPF: neutral (google.com: 2401:3900:2:1::2 is neither permitted nor denied by best guess record for domain of mpe@ellerman.id.au) client-ip=2401:3900:2:1::2;
Authentication-Results: mx.google.com;
       spf=neutral (google.com: 2401:3900:2:1::2 is neither permitted nor denied by best guess record for domain of mpe@ellerman.id.au) smtp.mailfrom=mpe@ellerman.id.au
Received: from authenticated.ozlabs.org (localhost [127.0.0.1])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange ECDHE (P-256) server-signature RSA-PSS (2048 bits) server-digest SHA256)
	(No client certificate requested)
	by ozlabs.org (Postfix) with ESMTPSA id 43pTZM2r3kz9sDK;
	Tue, 29 Jan 2019 12:34:51 +1100 (AEDT)
From: Michael Ellerman <mpe@ellerman.id.au>
To: Dave Hansen <dave.hansen@intel.com>, Bjorn Helgaas <bhelgaas@google.com>, Dave Hansen <dave.hansen@linux.intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Dan Williams <dan.j.williams@intel.com>, Dave Jiang <dave.jiang@intel.com>, zwisler@kernel.org, vishal.l.verma@intel.com, thomas.lendacky@amd.com, Andrew Morton <akpm@linux-foundation.org>, mhocko@suse.com, linux-nvdimm@lists.01.org, linux-mm@kvack.org, Huang Ying <ying.huang@intel.com>, Wu Fengguang <fengguang.wu@intel.com>, Jerome Glisse <jglisse@redhat.com>
Subject: Re: [PATCH 2/5] mm/resource: move HMM pr_debug() deeper into resource code
In-Reply-To: <b191ad4a-da4e-9bc7-4468-d6e4a8b3d66f@intel.com>
References: <20190124231441.37A4A305@viggo.jf.intel.com> <20190124231444.38182DD8@viggo.jf.intel.com> <CAErSpo4oSjQAxeRy8Tz_Jvo+cRovBvVx9WBeNb_P6PxT-A_XhA@mail.gmail.com> <b191ad4a-da4e-9bc7-4468-d6e4a8b3d66f@intel.com>
Date: Tue, 29 Jan 2019 12:34:50 +1100
Message-ID: <87imy8s0ud.fsf@concordia.ellerman.id.au>
MIME-Version: 1.0
Content-Type: text/plain
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Dave Hansen <dave.hansen@intel.com> writes:
> On 1/25/19 1:18 PM, Bjorn Helgaas wrote:
>> On Thu, Jan 24, 2019 at 5:21 PM Dave Hansen <dave.hansen@linux.intel.com> wrote:
>>> diff -puN kernel/resource.c~move-request_region-check kernel/resource.c
>>> --- a/kernel/resource.c~move-request_region-check       2019-01-24 15:13:14.453199539 -0800
>>> +++ b/kernel/resource.c 2019-01-24 15:13:14.458199539 -0800
>>> @@ -1123,6 +1123,16 @@ struct resource * __request_region(struc
>>>                 conflict = __request_resource(parent, res);
>>>                 if (!conflict)
>>>                         break;
>>> +               /*
>>> +                * mm/hmm.c reserves physical addresses which then
>>> +                * become unavailable to other users.  Conflicts are
>>> +                * not expected.  Be verbose if one is encountered.
>>> +                */
>>> +               if (conflict->desc == IORES_DESC_DEVICE_PRIVATE_MEMORY) {
>>> +                       pr_debug("Resource conflict with unaddressable "
>>> +                                "device memory at %#010llx !\n",
>>> +                                (unsigned long long)start);
>> 
>> I don't object to the change, but are you really OK with this being a
>> pr_debug() message that is only emitted when enabled via either the
>> dynamic debug mechanism or DEBUG being defined?  From the comments, it
>> seems more like a KERN_INFO sort of message.
>
> I left it consistent with the original message that was in the code.
> I'm happy to change it, though, if the consumers of it (Jerome,
> basically) want something different.

At least using pr_debug() doesn't match the comment, ie. the comment
says "Be verbose" but pr_debug() is silent by default.

cheers

