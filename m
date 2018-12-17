Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf1-f198.google.com (mail-pf1-f198.google.com [209.85.210.198])
	by kanga.kvack.org (Postfix) with ESMTP id 9DA8C8E0001
	for <linux-mm@kvack.org>; Mon, 17 Dec 2018 03:48:45 -0500 (EST)
Received: by mail-pf1-f198.google.com with SMTP id h11so11251684pfj.13
        for <linux-mm@kvack.org>; Mon, 17 Dec 2018 00:48:45 -0800 (PST)
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id t18si10062371pgu.476.2018.12.17.00.48.44
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 17 Dec 2018 00:48:44 -0800 (PST)
Received: from pps.filterd (m0098396.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.22/8.16.0.22) with SMTP id wBH8iXqs111100
	for <linux-mm@kvack.org>; Mon, 17 Dec 2018 03:48:43 -0500
Received: from e06smtp05.uk.ibm.com (e06smtp05.uk.ibm.com [195.75.94.101])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2pe8d8ghh7-1
	(version=TLSv1.2 cipher=AES256-GCM-SHA384 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Mon, 17 Dec 2018 03:48:43 -0500
Received: from localhost
	by e06smtp05.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <rppt@linux.ibm.com>;
	Mon, 17 Dec 2018 08:48:41 -0000
Date: Mon, 17 Dec 2018 10:48:36 +0200
From: Mike Rapoport <rppt@linux.ibm.com>
Subject: Re: Cgroups support for THP
References: <CAKhyrx-gbHjzWyeUERrXhH2CGMEMZeFX66Q-POD7Q+hKwWA1kw@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <CAKhyrx-gbHjzWyeUERrXhH2CGMEMZeFX66Q-POD7Q+hKwWA1kw@mail.gmail.com>
Message-Id: <20181217084836.GA22890@rapoport-lnx>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: vijay nag <vijunag@gmail.com>
Cc: linux-mm@kvack.org

On Mon, Dec 17, 2018 at 01:56:40PM +0530, vijay nag wrote:
> Hello Linux-MM,
> 
> My containerized application which is suppose to have a very low RSS(by default
> containers patterns are to have low memory footprint) seems to be getting its
> BSS segment RSS bloated due to THPs. Although there is a huge zero page
> support, the overhead seems to be at-least 2MB even when a byte is dirtied.
> Also there are tune-able to disable this feature,� but this seems to be a
> system wide setting. Is there a plan to make this setting cgroup aware ?

It's possible to control THP on per-mapping using madvise(MADV_NOHUGEPAGE)
and per-process using prctl(PR_SET_THP_DISABLE). 
 
> Thanks,
> Vijay Nag

-- 
Sincerely yours,
Mike.
