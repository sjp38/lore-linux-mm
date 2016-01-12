Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f170.google.com (mail-io0-f170.google.com [209.85.223.170])
	by kanga.kvack.org (Postfix) with ESMTP id 6D6724403D9
	for <linux-mm@kvack.org>; Tue, 12 Jan 2016 07:27:45 -0500 (EST)
Received: by mail-io0-f170.google.com with SMTP id g73so185908730ioe.3
        for <linux-mm@kvack.org>; Tue, 12 Jan 2016 04:27:45 -0800 (PST)
Received: from mail-io0-x22d.google.com (mail-io0-x22d.google.com. [2607:f8b0:4001:c06::22d])
        by mx.google.com with ESMTPS id z197si17476150iod.89.2016.01.12.04.27.44
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 12 Jan 2016 04:27:44 -0800 (PST)
Received: by mail-io0-x22d.google.com with SMTP id q21so381486395iod.0
        for <linux-mm@kvack.org>; Tue, 12 Jan 2016 04:27:44 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <alpine.DEB.2.20.1601120603250.4490@east.gentwo.org>
References: <5674A5C3.1050504@oracle.com>
	<alpine.DEB.2.20.1512210656120.7119@east.gentwo.org>
	<CAPub148SiOaVQbnA0AHRRDme7nyfeDKjYHEom5kLstqaE8ibZA@mail.gmail.com>
	<alpine.DEB.2.20.1601120603250.4490@east.gentwo.org>
Date: Tue, 12 Jan 2016 17:57:44 +0530
Message-ID: <CAPub1494LUuVFW1yJjMm_5ecCTzv1V3DsR=3JTbR54=iWzJdgA@mail.gmail.com>
Subject: Re: mm, vmstat: kernel BUG at mm/vmstat.c:1408!
From: Shiraz Hashim <shiraz.linux.kernel@gmail.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>
Cc: Sasha Levin <sasha.levin@oracle.com>, Michal Hocko <mhocko@suse.cz>, LKML <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>

On Tue, Jan 12, 2016 at 5:53 PM, Christoph Lameter <cl@linux.com> wrote:
> Does this fix it? I have not been able to reproduce the issue so far.

I too am not able to reproduce. Was just thinking what else can go
wrong in Sasha's setup.

-- 
regards
Shiraz Hashim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
