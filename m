Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with ESMTP id 7EA716B00B4
	for <linux-mm@kvack.org>; Thu, 26 Nov 2009 12:02:52 -0500 (EST)
Received: from d12nrmr1607.megacenter.de.ibm.com (d12nrmr1607.megacenter.de.ibm.com [9.149.167.49])
	by mtagate6.de.ibm.com (8.13.1/8.13.1) with ESMTP id nAQH2l5g032369
	for <linux-mm@kvack.org>; Thu, 26 Nov 2009 17:02:47 GMT
Received: from d12av03.megacenter.de.ibm.com (d12av03.megacenter.de.ibm.com [9.149.165.213])
	by d12nrmr1607.megacenter.de.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id nAQH2l2W1044694
	for <linux-mm@kvack.org>; Thu, 26 Nov 2009 18:02:47 +0100
Received: from d12av03.megacenter.de.ibm.com (loopback [127.0.0.1])
	by d12av03.megacenter.de.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id nAQH2l7I019453
	for <linux-mm@kvack.org>; Thu, 26 Nov 2009 18:02:47 +0100
Message-ID: <4B0EB4B6.5000702@free.fr>
Date: Thu, 26 Nov 2009 18:02:46 +0100
From: Daniel Lezcano <daniel.lezcano@free.fr>
MIME-Version: 1.0
Subject: Re: [PATCH RFC v0 0/3] cgroup notifications API and memory thresholds
References: <cover.1259248846.git.kirill@shutemov.name>
In-Reply-To: <cover.1259248846.git.kirill@shutemov.name>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: "Kirill A. Shutemov" <kirill@shutemov.name>
Cc: containers@lists.linux-foundation.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Paul Menage <menage@google.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, Andrew Morton <akpm@linux-foundation.org>, Pavel Emelyanov <xemul@openvz.org>
List-ID: <linux-mm.kvack.org>

Kirill A. Shutemov wrote:
> It's my first attempt to implement cgroup notifications API and memory
> thresholds on top of it. The idea of API was proposed by Paul Menage.
>
> It lacks some important features and need more testing, but I want publish
> it as soon as possible to get feedback from community.
>
> TODO:
>  - memory thresholds on root cgroup;
>  - memsw support;
>  - documentation.
>   
Maybe it would be interesting to do that for the /cgroup/<name>/tasks by 
sending in the event the number of tasks in the cgroup when it changes, 
so it more easy to detect 0 process event and then remove the cgroup 
directory, no ?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
