Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f198.google.com (mail-io0-f198.google.com [209.85.223.198])
	by kanga.kvack.org (Postfix) with ESMTP id BBD146B0003
	for <linux-mm@kvack.org>; Fri,  2 Mar 2018 08:42:04 -0500 (EST)
Received: by mail-io0-f198.google.com with SMTP id 19so8824105ios.12
        for <linux-mm@kvack.org>; Fri, 02 Mar 2018 05:42:04 -0800 (PST)
Received: from userp2130.oracle.com (userp2130.oracle.com. [156.151.31.86])
        by mx.google.com with ESMTPS id d7si1140269ith.12.2018.03.02.05.42.03
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 02 Mar 2018 05:42:03 -0800 (PST)
Received: from pps.filterd (userp2130.oracle.com [127.0.0.1])
	by userp2130.oracle.com (8.16.0.22/8.16.0.22) with SMTP id w22Dfalu037212
	for <linux-mm@kvack.org>; Fri, 2 Mar 2018 13:42:03 GMT
Received: from userv0022.oracle.com (userv0022.oracle.com [156.151.31.74])
	by userp2130.oracle.com with ESMTP id 2gf7an03r6-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK)
	for <linux-mm@kvack.org>; Fri, 02 Mar 2018 13:42:02 +0000
Received: from userv0122.oracle.com (userv0122.oracle.com [156.151.31.75])
	by userv0022.oracle.com (8.14.4/8.14.4) with ESMTP id w22Dg2rm028522
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=FAIL)
	for <linux-mm@kvack.org>; Fri, 2 Mar 2018 13:42:02 GMT
Received: from abhmp0002.oracle.com (abhmp0002.oracle.com [141.146.116.8])
	by userv0122.oracle.com (8.14.4/8.14.4) with ESMTP id w22Dg2DP003860
	for <linux-mm@kvack.org>; Fri, 2 Mar 2018 13:42:02 GMT
Received: by mail-ot0-f172.google.com with SMTP id g97so8715835otg.13
        for <linux-mm@kvack.org>; Fri, 02 Mar 2018 05:42:01 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20180302130541.GO15057@dhcp22.suse.cz>
References: <20180228030308.1116-1-pasha.tatashin@oracle.com> <20180302130541.GO15057@dhcp22.suse.cz>
From: Pavel Tatashin <pasha.tatashin@oracle.com>
Date: Fri, 2 Mar 2018 08:42:01 -0500
Message-ID: <CAOAebxvs0Nh6AkyPJS7e-B-cfeRqUZsQ23AOecOzH8YbneDOOg@mail.gmail.com>
Subject: Re: [v5 0/6] optimize memory hotplug
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Steve Sistare <steven.sistare@oracle.com>, Daniel Jordan <daniel.m.jordan@oracle.com>, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@techsingularity.net>, Linux Memory Management List <linux-mm@kvack.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Vlastimil Babka <vbabka@suse.cz>, Bharata B Rao <bharata@linux.vnet.ibm.com>, Thomas Gleixner <tglx@linutronix.de>, mingo@redhat.com, hpa@zytor.com, x86@kernel.org, dan.j.williams@intel.com, kirill.shutemov@linux.intel.com, bhe@redhat.com

Hi Michal,

Thank you for letting me know, its OK, the patches are in mm-tree, so
they are getting tested, and there is no rush.

Pavel

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
