Received: from zps76.corp.google.com (zps76.corp.google.com [172.25.146.76])
	by smtp-out.google.com with ESMTP id k8KIXTs9010567
	for <linux-mm@kvack.org>; Wed, 20 Sep 2006 11:33:29 -0700
Received: from smtp-out2.google.com (fpr16.prod.google.com [10.253.18.16])
	by zps76.corp.google.com with ESMTP id k8KFjBlw021943
	for <linux-mm@kvack.org>; Wed, 20 Sep 2006 11:33:25 -0700
Received: by smtp-out2.google.com with SMTP id 16so342482fpr
        for <linux-mm@kvack.org>; Wed, 20 Sep 2006 11:33:25 -0700 (PDT)
Message-ID: <6599ad830609201133k68cc1a0dr683137baa4e9be30@mail.google.com>
Date: Wed, 20 Sep 2006 11:33:25 -0700
From: "Paul Menage" <menage@google.com>
Subject: Re: [ckrm-tech] [patch00/05]: Containers(V2)- Introduction
In-Reply-To: <1158776824.28174.29.camel@lappy>
MIME-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
References: <1158718568.29000.44.camel@galaxy.corp.google.com>
	 <1158751720.8970.67.camel@twins> <4511626B.9000106@yahoo.com.au>
	 <1158767787.3278.103.camel@taijtu> <451173B5.1000805@yahoo.com.au>
	 <1158774657.8574.65.camel@galaxy.corp.google.com>
	 <Pine.LNX.4.64.0609201051550.31636@schroedinger.engr.sgi.com>
	 <1158775586.28174.27.camel@lappy>
	 <1158776099.8574.89.camel@galaxy.corp.google.com>
	 <1158776824.28174.29.camel@lappy>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Peter Zijlstra <a.p.zijlstra@chello.nl>
Cc: rohitseth@google.com, Nick Piggin <nickpiggin@yahoo.com.au>, CKRM-Tech <ckrm-tech@lists.sourceforge.net>, linux-kernel <linux-kernel@vger.kernel.org>, Linux Memory Management <linux-mm@kvack.org>, devel@openvz.org, Christoph Lameter <clameter@sgi.com>
List-ID: <linux-mm.kvack.org>

On 9/20/06, Peter Zijlstra <a.p.zijlstra@chello.nl> wrote:
>
> Yes, I read that in your patches, I was wondering how the cpuset
> approach would handle this.

The VM currently has support for letting vmas define their own memory
policies - so specifying that a file-backed vma gets its memory from a
particular set of memory nodes would accomplish that for the fake-node
approach. The mechanism for setting up the per-file/per-vma policies
would probably involve something originating in struct inode or struct
address_space.

Paul

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
