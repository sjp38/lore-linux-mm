Date: Thu, 27 Apr 2000 17:28:32 +0100
From: "Stephen C. Tweedie" <sct@redhat.com>
Subject: Re: [patch] 2.3.99-pre6-3 VM fixed
Message-ID: <20000427172832.D3792@redhat.com>
References: <Pine.LNX.4.21.0004261022260.16202-100000@duckman.conectiva>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <Pine.LNX.4.21.0004261022260.16202-100000@duckman.conectiva>; from riel@conectiva.com.br on Wed, Apr 26, 2000 at 10:36:10AM -0300
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: riel@nl.linux.org
Cc: linux-mm@kvack.org, linux-kernel@vger.rutgers.edu, torvalds@transmeta.com
List-ID: <linux-mm.kvack.org>

Hi,

On Wed, Apr 26, 2000 at 10:36:10AM -0300, Rik van Riel wrote:
> 
> The patch runs great in a variety of workloads I've tested here,
> but of course I'm not sure if it works as good as it should in
> *your* workload, so testing is wanted/needed/appreciated...

Well, on an 8GB box doing a "mtest -m1000 -r0 -w12" (ie. create 1GB
heap and fork off 12 writer sub-processes touching the heap at random),
I get a complete lockup just after the system goes into swap.  At one
point I was able to capture an EIP trace showing the kernel looping in
stext_lock and try_to_swap_out.

--Stephen
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
