Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f69.google.com (mail-pa0-f69.google.com [209.85.220.69])
	by kanga.kvack.org (Postfix) with ESMTP id 70CFA6B0271
	for <linux-mm@kvack.org>; Mon, 24 Oct 2016 21:22:30 -0400 (EDT)
Received: by mail-pa0-f69.google.com with SMTP id r13so1134084pag.1
        for <linux-mm@kvack.org>; Mon, 24 Oct 2016 18:22:30 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id l192si18109713pfc.169.2016.10.24.18.22.29
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 24 Oct 2016 18:22:29 -0700 (PDT)
Received: from pps.filterd (m0098410.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.17/8.16.0.17) with SMTP id u9P1IgqG098925
	for <linux-mm@kvack.org>; Mon, 24 Oct 2016 21:22:29 -0400
Received: from e23smtp03.au.ibm.com (e23smtp03.au.ibm.com [202.81.31.145])
	by mx0a-001b2d01.pphosted.com with ESMTP id 269krkuvuq-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Mon, 24 Oct 2016 21:22:29 -0400
Received: from localhost
	by e23smtp03.au.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <khandual@linux.vnet.ibm.com>;
	Tue, 25 Oct 2016 11:22:26 +1000
Received: from d23relay06.au.ibm.com (d23relay06.au.ibm.com [9.185.63.219])
	by d23dlp01.au.ibm.com (Postfix) with ESMTP id 21F1C2CE805A
	for <linux-mm@kvack.org>; Tue, 25 Oct 2016 12:22:24 +1100 (EST)
Received: from d23av01.au.ibm.com (d23av01.au.ibm.com [9.190.234.96])
	by d23relay06.au.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id u9P1MOdx13434928
	for <linux-mm@kvack.org>; Tue, 25 Oct 2016 12:22:24 +1100
Received: from d23av01.au.ibm.com (localhost [127.0.0.1])
	by d23av01.au.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id u9P1MN2x007766
	for <linux-mm@kvack.org>; Tue, 25 Oct 2016 12:22:23 +1100
Subject: Re: [RFC 1/8] mm: Define coherent device memory node
References: <1477283517-2504-1-git-send-email-khandual@linux.vnet.ibm.com>
 <1477283517-2504-2-git-send-email-khandual@linux.vnet.ibm.com>
 <580E4043.4090200@intel.com>
From: Anshuman Khandual <khandual@linux.vnet.ibm.com>
Date: Tue, 25 Oct 2016 06:52:19 +0530
MIME-Version: 1.0
In-Reply-To: <580E4043.4090200@intel.com>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Message-Id: <580EB3CB.5080200@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave.hansen@intel.com>, Anshuman Khandual <khandual@linux.vnet.ibm.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
Cc: mhocko@suse.com, js1304@gmail.com, vbabka@suse.cz, mgorman@suse.de, minchan@kernel.org, akpm@linux-foundation.org, aneesh.kumar@linux.vnet.ibm.com, bsingharora@gmail.com

On 10/24/2016 10:39 PM, Dave Hansen wrote:
>> +#ifdef CONFIG_COHERENT_DEVICE
>> > +#define node_cdm(nid)          (NODE_DATA(nid)->coherent_device)
>> > +#define set_cdm_isolation(nid) (node_cdm(nid) = 1)
>> > +#define clr_cdm_isolation(nid) (node_cdm(nid) = 0)
>> > +#define isolated_cdm_node(nid) (node_cdm(nid) == 1)
>> > +#else
>> > +#define set_cdm_isolation(nid) ()
>> > +#define clr_cdm_isolation(nid) ()
>> > +#define isolated_cdm_node(nid) (0)
>> > +#endif
> FWIW, I think adding all this "cdm" gunk in the names is probably a bad
> thing.
> 
> I can think of other memory types that are coherent, but
> non-device-based that might want behavior like this.

Hmm, I was not aware about non-device-based coherent memory. Could you
please name some of them ? If thats the case we need to change CDM to
some thing which can accommodate both device and non device based
coherent memory. May be like "Differentiated/special coherent memory".
But it needs to communicate that its not system RAM. Thats the idea.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
