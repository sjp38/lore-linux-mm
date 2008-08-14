Received: from d23relay03.au.ibm.com (d23relay03.au.ibm.com [202.81.18.234])
	by ausmtp04.au.ibm.com (8.13.8/8.13.8) with ESMTP id m7EL9mdF154304
	for <linux-mm@kvack.org>; Fri, 15 Aug 2008 07:09:51 +1000
Received: from d23av03.au.ibm.com (d23av03.au.ibm.com [9.190.234.97])
	by d23relay03.au.ibm.com (8.13.8/8.13.8/NCO v9.0) with ESMTP id m7EKwUdH2740456
	for <linux-mm@kvack.org>; Fri, 15 Aug 2008 06:58:30 +1000
Received: from d23av03.au.ibm.com (loopback [127.0.0.1])
	by d23av03.au.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id m7EKwUqr029747
	for <linux-mm@kvack.org>; Fri, 15 Aug 2008 06:58:30 +1000
Message-ID: <48A49C78.7070100@linux.vnet.ibm.com>
Date: Fri, 15 Aug 2008 02:28:32 +0530
From: Balbir Singh <balbir@linux.vnet.ibm.com>
Reply-To: balbir@linux.vnet.ibm.com
MIME-Version: 1.0
Subject: Re: [PATCH 1/1] mm_owner: fix cgroup null dereference
References: <1218745013-9537-1-git-send-email-jirislaby@gmail.com>
In-Reply-To: <1218745013-9537-1-git-send-email-jirislaby@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Jiri Slaby <jirislaby@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, containers@lists.linux-foundation.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

Jiri Slaby wrote:
> Hi,
> 
> found this in mmotm, a fix for
> mm-owner-fix-race-between-swap-and-exit.patch
> 

Thanks for catching this

Acked-by: Balbir Singh <balbir@linux.vnet.ibm.com>

-- 
	Balbir

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
