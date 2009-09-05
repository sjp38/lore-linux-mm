Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id 67F276B0083
	for <linux-mm@kvack.org>; Sat,  5 Sep 2009 07:34:31 -0400 (EDT)
Date: Sat, 5 Sep 2009 12:33:52 +0100 (BST)
From: Hugh Dickins <hugh.dickins@tiscali.co.uk>
Subject: Re: improving checksum cpu consumption in ksm
In-Reply-To: <7928e7bd0909041529i6d745955paa636206b9409587@mail.gmail.com>
Message-ID: <Pine.LNX.4.64.0909051225450.5114@sister.anvils>
References: <4A983C52.7000803@redhat.com>  <Pine.LNX.4.64.0908312233340.23516@sister.anvils>
  <4A9FB83F.2000605@redhat.com>  <Pine.LNX.4.64.0909031535290.13918@sister.anvils>
 <7928e7bd0909041529i6d745955paa636206b9409587@mail.gmail.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Moussa Ba <moussa.a.ba@gmail.com>
Cc: Izik Eidus <ieidus@redhat.com>, Andrea Arcangeli <aarcange@redhat.com>, Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>, linux-mm@kvack.org, jaredeh@gmail.com
List-ID: <linux-mm.kvack.org>

On Fri, 4 Sep 2009, Moussa Ba wrote:

> Just to add to the discussion, we have also seen a high cpu usage for
> KSM.  In our case however it is more serious as the system that KSM is
> running on is battery powered  with a weaker processor.  With KSM
> constantly running, the effect on the battery life is significant.

Sounds like it would be a good idea for us to throttle back ksmd
when the system is otherwise idle.  Though quite a bit of thought
should go into how we decide "idle" for that.

> 
> I like the idea of dirty bit tracking as it would obviate the need to
> rehash once we know the page has not been dirtied.  We have been
> working on a patch that adds dirty bit clearing from user space,
> similar to the clear_refs entry under /proc/pid/.  In our instance we
> use this mechanism to measure page accesses and write frequency on
> ANONYMOUS pages, file backed pages or both.  Could this potentially
> pose a problem if KSM decides to use that mechanism for page state
> tracking?

Yes, KSM's use of the bit would interfere with your statistics, and
your use of the bit would interfere with KSM's efficiency: better
not use them both together (or keep yours off MADV_MERGEABLE areas).

Hugh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
