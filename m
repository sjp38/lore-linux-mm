Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id 21B116B0069
	for <linux-mm@kvack.org>; Tue,  3 Jan 2017 04:07:20 -0500 (EST)
Received: by mail-pf0-f198.google.com with SMTP id 83so732320625pfx.1
        for <linux-mm@kvack.org>; Tue, 03 Jan 2017 01:07:20 -0800 (PST)
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id f35si68382110plh.212.2017.01.03.01.07.18
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 03 Jan 2017 01:07:19 -0800 (PST)
Received: from pps.filterd (m0098416.ppops.net [127.0.0.1])
	by mx0b-001b2d01.pphosted.com (8.16.0.17/8.16.0.17) with SMTP id v0393UwE134425
	for <linux-mm@kvack.org>; Tue, 3 Jan 2017 04:07:18 -0500
Received: from e23smtp01.au.ibm.com (e23smtp01.au.ibm.com [202.81.31.143])
	by mx0b-001b2d01.pphosted.com with ESMTP id 27r5kayc03-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Tue, 03 Jan 2017 04:07:18 -0500
Received: from localhost
	by e23smtp01.au.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <khandual@linux.vnet.ibm.com>;
	Tue, 3 Jan 2017 19:07:15 +1000
Received: from d23relay06.au.ibm.com (d23relay06.au.ibm.com [9.185.63.219])
	by d23dlp01.au.ibm.com (Postfix) with ESMTP id 6C7E02CE8054
	for <linux-mm@kvack.org>; Tue,  3 Jan 2017 20:07:12 +1100 (EST)
Received: from d23av04.au.ibm.com (d23av04.au.ibm.com [9.190.235.139])
	by d23relay06.au.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id v0397DPH51838998
	for <linux-mm@kvack.org>; Tue, 3 Jan 2017 20:07:13 +1100
Received: from d23av04.au.ibm.com (localhost [127.0.0.1])
	by d23av04.au.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id v0397CJZ021032
	for <linux-mm@kvack.org>; Tue, 3 Jan 2017 20:07:12 +1100
Subject: Re: [RFC] nodemask: Consider MAX_NUMNODES inside node_isset
References: <20170103082753.25758-1-khandual@linux.vnet.ibm.com>
 <20170103084418.GC30111@dhcp22.suse.cz>
From: Anshuman Khandual <khandual@linux.vnet.ibm.com>
Date: Tue, 3 Jan 2017 14:37:09 +0530
MIME-Version: 1.0
In-Reply-To: <20170103084418.GC30111@dhcp22.suse.cz>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Message-Id: <6c7ecb18-2ad0-f38a-1dc8-3c6c405b87ce@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>, Anshuman Khandual <khandual@linux.vnet.ibm.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, vbabka@suse.cz, akpm@linux-foundation.org

On 01/03/2017 02:14 PM, Michal Hocko wrote:
> On Tue 03-01-17 13:57:53, Anshuman Khandual wrote:
>> node_isset can give incorrect result if the node number is beyond the
>> bitmask size (MAX_NUMNODES in this case) which is not checked inside
>> test_bit. Hence check for the bit limits (MAX_NUMNODES) inside the
>> node_isset function before calling test_bit.
> Could you be more specific when such a thing might happen? Have you seen
> any in-kernel user who would give such a bogus node?

Have not seen this through any in-kernel use case. While rebasing the CDM
zonelist rebuilding series, I came across this through an error path when
a bogus node value of 256 (MAX_NUMNODES on POWER) is received when we call
first_node() on an empty nodemask (which itself seems weird as well).

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
