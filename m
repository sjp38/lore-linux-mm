Return-Path: <SRS0=43/C=RJ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.9 required=3.0 tests=FROM_EXCESS_BASE64,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 0BBF8C43381
	for <linux-mm@archiver.kernel.org>; Wed,  6 Mar 2019 11:44:59 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id C82BB2064A
	for <linux-mm@archiver.kernel.org>; Wed,  6 Mar 2019 11:44:58 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org C82BB2064A
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=suse.de
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 5CB698E0002; Wed,  6 Mar 2019 06:44:58 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 57A9E8E0004; Wed,  6 Mar 2019 06:44:58 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 476858E0002; Wed,  6 Mar 2019 06:44:58 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id E2CEE8E0002
	for <linux-mm@kvack.org>; Wed,  6 Mar 2019 06:44:57 -0500 (EST)
Received: by mail-ed1-f69.google.com with SMTP id a21so6321820eda.3
        for <linux-mm@kvack.org>; Wed, 06 Mar 2019 03:44:57 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=8YfZSnQB+LVGFyraNiu3foi3/Wiq/19xgJ3IqcCf2/0=;
        b=NAn7qLJUcyiIc54jERD+HJg6/ZuAs8z4g/5tj6Qtn2EX7j02wBB9zgOe0IBPPRrO6A
         pIpvWuQ6GC4Z7cGbAFOjrzEFoIVKNXSkZqmB5cdFusH/YctkyW4ytQSchBR0UjVQM2VK
         pm7rs1OwCAvw5xVwzV5DaDndc3304tLX9xFBsJCLlHM0EZj9QOr7ABRTZG+rGytYlWMP
         fdodP4ryh5/hZNjE8s4bNxFnGZY1+UJ97h8SixE+ulIcqT7uo2yMIhqAWWApN3HnkB/n
         RmiHNPrDzL3A2n4n39EjIukzh9ZTuiMqfHdHMt+PTl8qTSisj5NHFkrhJMDIDT/JQRAt
         eO4Q==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of msuchanek@suse.de designates 195.135.220.15 as permitted sender) smtp.mailfrom=msuchanek@suse.de
X-Gm-Message-State: APjAAAUvrAX6LZfNg2lJGKhjJCXBK4RkG/n/4SyGZe4ziYh+ntPOzjJB
	kPVzNnOuCLUVOsmp8zFsXcoR3ChYTdappL1MLstTeiO1m8xWo6HQRXylVdqVCF+RUuyWMDOyQo6
	AL6T6zOCD2X9TEce8LXAMWVWsapkRM397fUhwqFi7BKoMdtjpC2cgyeIJWSpmp3uJ7A==
X-Received: by 2002:a17:906:2e9b:: with SMTP id o27mr3670272eji.98.1551872697528;
        Wed, 06 Mar 2019 03:44:57 -0800 (PST)
X-Google-Smtp-Source: APXvYqw2M8KXTYGtezX7cTsMdUj/HiI1A5UH2wJ9REoTcoVx1W1Mw9J1aJ1+PX+vBAeSRIW89ThF
X-Received: by 2002:a17:906:2e9b:: with SMTP id o27mr3670224eji.98.1551872696581;
        Wed, 06 Mar 2019 03:44:56 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1551872696; cv=none;
        d=google.com; s=arc-20160816;
        b=wVNX7otdY9wmKdn/ALPJ6O6IjQVZN8yB0mYVJK0TWuMvkFoweoKEhnQZbIueBBcRIQ
         7hsJi/2wYdUR4/Vh282klO7HTsyl3scBMPPFWxmPz26P9mywwVX9nP1G8RECiwhWsK/F
         bNRTs+Y7OvMMmiPVSPl4coRlbm5BXgPSPns/4LvP7UPlfyKCwycmehn9CZ/kFPM9Cy12
         7dVTa3fdsiBygGjXyCUHqQMCF70EUShlPDOZYturK4dDD2tJeS14tRqLdTYBaZCi4hsy
         aricoGgk7q0r4JGN2kn5IiadvbyvFNmN0rYS/dAnhTIpYawgwrNLs4a9U7Oc0FDcYf8L
         rN8A==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:subject:cc:to:from:date;
        bh=8YfZSnQB+LVGFyraNiu3foi3/Wiq/19xgJ3IqcCf2/0=;
        b=C6hAkp1UuPSMDZwX3GLWH39pJNFPytFe0iX3lpii+kc6OETcYEgfhRFlmeCFrniLfH
         dXLll3B8o+iI7a9KkmFQU3NhilF5T/29wU4r0rCep8Cw879l/M/2wT8s9BmZUnPHly73
         A+ZhUv/jyHLagsBIXRRPsf6nffjzTnRrkWjM2BCu46kyd+rQ5aWW7B54DrpHNESDYGzN
         Z9OmFQyv9vil6y/J0zI5NSiFjQhhTXJdzzpcSVKQP+y/2f0LKsyVx+nS3p2GyFt7ymrV
         lVZ0DMZoTnXO/5mNOBXS43pslb19pOBn7+ymVajCFiSeVQ+tzrQXrSWsrf3VbcJvRh7L
         PG1w==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of msuchanek@suse.de designates 195.135.220.15 as permitted sender) smtp.mailfrom=msuchanek@suse.de
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id c10si535671edc.119.2019.03.06.03.44.56
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 06 Mar 2019 03:44:56 -0800 (PST)
Received-SPF: pass (google.com: domain of msuchanek@suse.de designates 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of msuchanek@suse.de designates 195.135.220.15 as permitted sender) smtp.mailfrom=msuchanek@suse.de
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id 13F9DB12F;
	Wed,  6 Mar 2019 11:44:56 +0000 (UTC)
Date: Wed, 6 Mar 2019 12:44:53 +0100
From: Michal =?UTF-8?B?U3VjaMOhbmVr?= <msuchanek@suse.de>
To: "Aneesh Kumar K.V" <aneesh.kumar@linux.ibm.com>
Cc: Dan Williams <dan.j.williams@intel.com>, Oliver <oohall@gmail.com>, Jan
 Kara <jack@suse.cz>, linux-nvdimm@lists.01.org, Linux Kernel Mailing List
 <linux-kernel@vger.kernel.org>, Linux MM <linux-mm@kvack.org>, Ross Zwisler
 <zwisler@kernel.org>, Andrew Morton <akpm@linux-foundation.org>,
 linuxppc-dev <linuxppc-dev@lists.ozlabs.org>, "Kirill A . Shutemov"
 <kirill.shutemov@linux.intel.com>
Subject: Re: [PATCH 2/2] mm/dax: Don't enable huge dax mapping by default
Message-ID: <20190306124453.126d36d8@naga.suse.cz>
In-Reply-To: <87k1hc8iqa.fsf@linux.ibm.com>
References: <20190228083522.8189-1-aneesh.kumar@linux.ibm.com>
	<20190228083522.8189-2-aneesh.kumar@linux.ibm.com>
	<CAOSf1CHjkyX2NTex7dc1AEHXSDcWA_UGYX8NoSyHpb5s_RkwXQ@mail.gmail.com>
	<CAPcyv4jhEvijybSVsy+wmvgqfvyxfePQ3PUqy1hhmVmPtJTyqQ@mail.gmail.com>
	<87k1hc8iqa.fsf@linux.ibm.com>
X-Mailer: Claws Mail 3.17.3 (GTK+ 2.24.32; x86_64-suse-linux-gnu)
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, 06 Mar 2019 14:47:33 +0530
"Aneesh Kumar K.V" <aneesh.kumar@linux.ibm.com> wrote:

> Dan Williams <dan.j.williams@intel.com> writes:
> 
> > On Thu, Feb 28, 2019 at 1:40 AM Oliver <oohall@gmail.com> wrote:  
> >>
> >> On Thu, Feb 28, 2019 at 7:35 PM Aneesh Kumar K.V
> >> <aneesh.kumar@linux.ibm.com> wrote:  
 
> Also even if the user decided to not use THP, by
> echo "never" > transparent_hugepage/enabled , we should continue to map
> dax fault using huge page on platforms that can support huge pages.

Is this a good idea?

This knob is there for a reason. In some situations having huge pages
can severely impact performance of the system (due to host-guest
interaction or whatever) and the ability to really turn off all THP
would be important in those cases, right?

Thanks

Michal

