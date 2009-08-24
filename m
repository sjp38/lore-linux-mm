Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id 564AE6B0082
	for <linux-mm@kvack.org>; Tue, 25 Aug 2009 15:37:32 -0400 (EDT)
Received: from imap1.linux-foundation.org (imap1.linux-foundation.org [140.211.169.55])
	by smtp1.linux-foundation.org (8.14.2/8.13.5/Debian-3ubuntu1.1) with ESMTP id n7PJbUkE016764
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=NO)
	for <linux-mm@kvack.org>; Tue, 25 Aug 2009 12:37:31 -0700
Date: Mon, 24 Aug 2009 16:21:55 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: VM issue causing high CPU loads
Message-Id: <20090824162155.ce323f08.akpm@linux-foundation.org>
In-Reply-To: <4A92A25A.4050608@yohan.staff.proxad.net>
References: <4A92A25A.4050608@yohan.staff.proxad.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Yohan <kernel@yohan.staff.proxad.net>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, 24 Aug 2009 16:23:22 +0200
Yohan <kernel@yohan.staff.proxad.net> wrote:

> Hi,
> 
>     Is someone have an idea for that :
> 
>         http://bugzilla.kernel.org/show_bug.cgi?id=14024
> 

Please generate a kernel profile to work out where all the CPU tie is
being spent.  Documentation/basic_profiling.txt is a starting point.

Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
