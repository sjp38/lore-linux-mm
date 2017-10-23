Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f200.google.com (mail-qt0-f200.google.com [209.85.216.200])
	by kanga.kvack.org (Postfix) with ESMTP id 657336B0253
	for <linux-mm@kvack.org>; Sun, 22 Oct 2017 23:07:41 -0400 (EDT)
Received: by mail-qt0-f200.google.com with SMTP id h7so14330687qth.13
        for <linux-mm@kvack.org>; Sun, 22 Oct 2017 20:07:41 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id 11si3443591qts.306.2017.10.22.20.07.40
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 22 Oct 2017 20:07:40 -0700 (PDT)
Received: from pps.filterd (m0098409.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.21/8.16.0.21) with SMTP id v9N33wGJ127392
	for <linux-mm@kvack.org>; Sun, 22 Oct 2017 23:07:39 -0400
Received: from e06smtp10.uk.ibm.com (e06smtp10.uk.ibm.com [195.75.94.106])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2ds3j2yvhj-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Sun, 22 Oct 2017 23:07:39 -0400
Received: from localhost
	by e06smtp10.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <khandual@linux.vnet.ibm.com>;
	Mon, 23 Oct 2017 04:07:37 +0100
Received: from d23av05.au.ibm.com (d23av05.au.ibm.com [9.190.234.119])
	by b06cxnps4074.portsmouth.uk.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id v9N37YxH15204552
	for <linux-mm@kvack.org>; Mon, 23 Oct 2017 03:07:35 GMT
Received: from d23av05.au.ibm.com (localhost [127.0.0.1])
	by d23av05.au.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id v9N37XbR027264
	for <linux-mm@kvack.org>; Mon, 23 Oct 2017 14:07:33 +1100
Subject: Re: [RFC] mm/swap: Rename pagevec_lru_move_fn() as
 pagevec_lruvec_move_fn()
References: <20171019083314.12614-1-khandual@linux.vnet.ibm.com>
 <20171019152918.2wrn6slrq7ashvpj@dhcp22.suse.cz>
From: Anshuman Khandual <khandual@linux.vnet.ibm.com>
Date: Mon, 23 Oct 2017 08:37:31 +0530
MIME-Version: 1.0
In-Reply-To: <20171019152918.2wrn6slrq7ashvpj@dhcp22.suse.cz>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Message-Id: <bd9e0b37-ab4b-32da-63b9-425089f9ec00@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>, Anshuman Khandual <khandual@linux.vnet.ibm.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org

On 10/19/2017 08:59 PM, Michal Hocko wrote:
> On Thu 19-10-17 14:03:14, Anshuman Khandual wrote:
>> The function pagevec_lru_move_fn() actually moves pages from various
>> per cpu pagevecs into per node lruvecs with a custom function which
>> knows how to handle individual pages present in any given pagevec.
>> Because it does movement between pagevecs and lruvecs as whole not
>> to an individual list element, the name should reflect it.
> I find the original name quite understandable (and shorter). I do not
> think this is worth changing. It is just a code churn without a good
> reason.
> 

Sure, I understand.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
