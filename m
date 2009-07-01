Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id 7C9E56B0055
	for <linux-mm@kvack.org>; Wed,  1 Jul 2009 06:32:17 -0400 (EDT)
Date: Wed, 1 Jul 2009 12:33:14 +0200
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: Re: KSM: current madvise rollup
Message-ID: <20090701103314.GB14272@random.random>
References: <Pine.LNX.4.64.0906291419440.5078@sister.anvils>
 <4A49E051.1080400@redhat.com>
 <Pine.LNX.4.64.0906301518370.967@sister.anvils>
 <4A4A5C56.5000109@redhat.com>
 <Pine.LNX.4.64.0907010057320.4255@sister.anvils>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.64.0907010057320.4255@sister.anvils>
Sender: owner-linux-mm@kvack.org
To: Hugh Dickins <hugh.dickins@tiscali.co.uk>
Cc: Izik Eidus <ieidus@redhat.com>, Rik van Riel <riel@redhat.com>, Chris Wright <chrisw@redhat.com>, Nick Piggin <nickpiggin@yahoo.com.au>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hi Hugh!

On Wed, Jul 01, 2009 at 03:03:58AM +0100, Hugh Dickins wrote:
> up with evidence for doing it differently - I think there's scope
> for academic papers on the behaviour of the unstable tree.

Eheh, I covered some of the behaviour of the unstable tree in the KSM
paper @ LinuxSymposium (downloadable in a few weeks) and I will ""try""
to cover some of it in my presentation as well ;).

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
