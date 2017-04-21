Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f199.google.com (mail-io0-f199.google.com [209.85.223.199])
	by kanga.kvack.org (Postfix) with ESMTP id 9263E6B0311
	for <linux-mm@kvack.org>; Fri, 21 Apr 2017 15:30:07 -0400 (EDT)
Received: by mail-io0-f199.google.com with SMTP id d203so154688741iof.20
        for <linux-mm@kvack.org>; Fri, 21 Apr 2017 12:30:07 -0700 (PDT)
Received: from aserp1040.oracle.com (aserp1040.oracle.com. [141.146.126.69])
        by mx.google.com with ESMTPS id m186si3459219itc.8.2017.04.21.12.30.06
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 21 Apr 2017 12:30:06 -0700 (PDT)
Received: from userv0021.oracle.com (userv0021.oracle.com [156.151.31.71])
	by aserp1040.oracle.com (Sentrion-MTA-4.3.2/Sentrion-MTA-4.3.2) with ESMTP id v3LJU4Xp028721
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK)
	for <linux-mm@kvack.org>; Fri, 21 Apr 2017 19:30:05 GMT
Received: from userv0121.oracle.com (userv0121.oracle.com [156.151.31.72])
	by userv0021.oracle.com (8.14.4/8.14.4) with ESMTP id v3LJU4Z4024346
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK)
	for <linux-mm@kvack.org>; Fri, 21 Apr 2017 19:30:04 GMT
Received: from abhmp0003.oracle.com (abhmp0003.oracle.com [141.146.116.9])
	by userv0121.oracle.com (8.14.4/8.13.8) with ESMTP id v3LJU4MH012825
	for <linux-mm@kvack.org>; Fri, 21 Apr 2017 19:30:04 GMT
Date: Fri, 21 Apr 2017 22:29:58 +0300
From: Dan Carpenter <dan.carpenter@oracle.com>
Subject: Re: [bug report] hugetlbfs: fix offset overflow in hugetlbfs mmap
Message-ID: <20170421192958.riy5bhdqp6cxhl6e@mwanda>
References: <20170421105724.j4o2j5zj2jjkjges@mwanda>
 <aa82140c-248f-143d-2b14-142e4775df65@oracle.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <aa82140c-248f-143d-2b14-142e4775df65@oracle.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mike Kravetz <mike.kravetz@oracle.com>
Cc: linux-mm@kvack.org

I only send new warnings, but in this case it doesn't find any similar
bugs in hugetlbfs.  It's specifically looking for code like
"(foo + bar < foo)" where the addition operation is signed.

Could you CC me on the fixes, just for reference and maybe I can check
for those as well.

regards,
dan carpenter

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
