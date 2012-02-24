Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx111.postini.com [74.125.245.111])
	by kanga.kvack.org (Postfix) with SMTP id 7D3446B004A
	for <linux-mm@kvack.org>; Fri, 24 Feb 2012 11:48:31 -0500 (EST)
Received: from /spool/local
	by e7.ny.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <dave@linux.vnet.ibm.com>;
	Fri, 24 Feb 2012 11:48:30 -0500
Received: from d01relay06.pok.ibm.com (d01relay06.pok.ibm.com [9.56.227.116])
	by d01dlp02.pok.ibm.com (Postfix) with ESMTP id 144216E804A
	for <linux-mm@kvack.org>; Fri, 24 Feb 2012 11:48:27 -0500 (EST)
Received: from d01av04.pok.ibm.com (d01av04.pok.ibm.com [9.56.224.64])
	by d01relay06.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id q1OGmQWq2801856
	for <linux-mm@kvack.org>; Fri, 24 Feb 2012 11:48:26 -0500
Received: from d01av04.pok.ibm.com (loopback [127.0.0.1])
	by d01av04.pok.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id q1OGmQRQ031216
	for <linux-mm@kvack.org>; Fri, 24 Feb 2012 11:48:26 -0500
Message-ID: <4F47BF56.6010602@linux.vnet.ibm.com>
Date: Fri, 24 Feb 2012 08:48:22 -0800
From: Dave Hansen <dave@linux.vnet.ibm.com>
MIME-Version: 1.0
Subject: Re: [RFC][PATCH] fix move/migrate_pages() race on task struct
References: <20120223180740.C4EC4156@kernel> <alpine.DEB.2.00.1202231240590.9878@router.home> <4F468F09.5050200@linux.vnet.ibm.com> <alpine.DEB.2.00.1202231334290.10914@router.home> <4F469BC7.50705@linux.vnet.ibm.com> <alpine.DEB.2.00.1202231536240.13554@router.home> <m1ehtkapn9.fsf@fess.ebiederm.org> <alpine.DEB.2.00.1202240859340.2621@router.home>
In-Reply-To: <alpine.DEB.2.00.1202240859340.2621@router.home>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>
Cc: "Eric W. Biederman" <ebiederm@xmission.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On 02/24/2012 07:20 AM, Christoph Lameter wrote:
> Subject: migration: Do not do rcu_read_unlock until the last time we need the task_struct pointer
> 
> Migration functions perform the rcu_read_unlock too early. As a result the
> task pointed to may change. Bugs were introduced when adding security checks
> because rcu_unlock/lock sequences were inserted. Plus the security checks
> and do_move_pages used the task_struct pointer after rcu_unlock.
> 
> Fix those issues by removing the unlock/lock sequences and moving the
> rcu_read_unlock after the last use of the task struct pointer.
> 
> Signed-off-by: Christoph Lameter <cl@linux.com>

It doesn't fix the code duplication, but it definitely does fix the bug
I was originally trying to address.

Acked-by: Dave Hansen <dave@linux.vnet.ibm.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
