Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id 82A7A6B0233
	for <linux-mm@kvack.org>; Mon, 10 May 2010 13:12:57 -0400 (EDT)
From: "Sean Hefty" <sean.hefty@intel.com>
References: <1271943493-12120-1-git-send-email-ebmunson@us.ibm.com> <01C0A6AB-E4B6-4B56-AFAE-52952D152110@cisco.com>
Subject: RE: [PATCH] ummunotify: Userspace support for MMU notifications V2
Date: Mon, 10 May 2010 10:12:56 -0700
Message-ID: <56643C62C30044F0A734365A5274C821@amr.corp.intel.com>
MIME-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 7bit
In-Reply-To: <01C0A6AB-E4B6-4B56-AFAE-52952D152110@cisco.com>
Sender: owner-linux-mm@kvack.org
To: 'Jeff Squyres' <jsquyres@cisco.com>, Eric B Munson <ebmunson@us.ibm.com>
Cc: akpm@linux-foundation.org, linux-kernel@vger.kernel.org, linux-rdma@vger.kernel.org, linux-mm@kvack.org, rolandd@cisco.com, peterz@infradead.org, mingo@elte.hu, pavel@ucw.cz, randy.dunlap@oracle.com
List-ID: <linux-mm.kvack.org>

>> As discussed in <http://article.gmane.org/gmane.linux.drivers.openib/61925>
>> and follow-up messages, libraries using RDMA would like to track
>> precisely when application code changes memory mapping via free(),
>> munmap(), etc.  Current pure-userspace solutions using malloc hooks
>> and other tricks are not robust, and the feeling among experts is that
>> the issue is unfixable without kernel help.
>
>Sorry for not replying earlier -- just to throw in my $0.02 here: the MPI
>community is *very interested* in having this stuff in upstream kernels.  It
>solves a fairly major problem for us.
>
>Open MPI (www.open-mpi.org) is ready to pretty much immediately take advantage
>of these capabilities.  The code to use ummunotify is in a Mercurial branch;
>we're only waiting for ummunotify to go upstream before committing our support
>for it to our main SVN development trunk.

Intel's MPI team has examined this proposal as well and would also like to see
this merged upstream.  It is helpful implementing MPI over RDMA devices.

- Sean

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
