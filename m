Received: from sd0109e.au.ibm.com (d23rh905.au.ibm.com [202.81.18.225])
	by ausmtp04.au.ibm.com (8.13.8/8.13.8) with ESMTP id l4O7v5Fs169022
	for <linux-mm@kvack.org>; Thu, 24 May 2007 17:57:08 +1000
Received: from d23av04.au.ibm.com (d23av04.au.ibm.com [9.190.250.237])
	by sd0109e.au.ibm.com (8.13.8/8.13.8/NCO v8.3) with ESMTP id l4O7e83h149722
	for <linux-mm@kvack.org>; Thu, 24 May 2007 17:40:10 +1000
Received: from d23av04.au.ibm.com (loopback [127.0.0.1])
	by d23av04.au.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l4O7aZYV025842
	for <linux-mm@kvack.org>; Thu, 24 May 2007 17:36:35 +1000
Message-ID: <4655407A.4090104@linux.vnet.ibm.com>
Date: Thu, 24 May 2007 13:06:26 +0530
From: Balbir Singh <balbir@linux.vnet.ibm.com>
Reply-To: balbir@linux.vnet.ibm.com
MIME-Version: 1.0
Subject: Re: RSS controller v2 Test results (lmbench )
References: <464C95D4.7070806@linux.vnet.ibm.com> <20070517112357.7adc4763.akpm@linux-foundation.org> <4651B4BF.9040608@sw.ru>
In-Reply-To: <4651B4BF.9040608@sw.ru>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Kirill Korotaev <dev@sw.ru>
Cc: Andrew Morton <akpm@linux-foundation.org>, Pavel Emelianov <xemul@sw.ru>, Paul Menage <menage@google.com>, devel@openvz.org, Linux Containers <containers@lists.osdl.org>, linux kernel mailing list <linux-kernel@vger.kernel.org>, Linux Memory Management List <linux-mm@kvack.org>, Vaidyanathan Srinivasan <svaidy@linux.vnet.ibm.com>, "Eric W. Biederman" <ebiederm@xmission.com>, Herbert Poetzl <herbert@13thfloor.at>
List-ID: <linux-mm.kvack.org>

Kirill Korotaev wrote:
>> Where do we stand on all of this now anyway?  I was thinking of getting Paul's
>> changes into -mm soon, see what sort of calamities that brings about.
> I think we can merge Paul's patches with *interfaces* and then switch to
> developing/reviewing/commiting resource subsytems.
> RSS control had good feedback so far from a number of people
> and is a first candidate imho.
> 

Yes, I completely agree!

> Thanks,
> Kirill
> 


-- 
	Warm Regards,
	Balbir Singh
	Linux Technology Center
	IBM, ISTL

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
