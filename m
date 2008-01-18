Date: Fri, 18 Jan 2008 10:54:59 -0800 (PST)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [PATCH 0/3] x86: Reduce memory and intra-node effects with large
 count NR_CPUs fixup
In-Reply-To: <4790A29F.9000006@sgi.com>
Message-ID: <Pine.LNX.4.64.0801181054180.30775@schroedinger.engr.sgi.com>
References: <20080117223546.419383000@sgi.com> <478FD9D9.7030009@sgi.com>
 <20080118092352.GH24337@elte.hu> <4790A29F.9000006@sgi.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Mike Travis <travis@sgi.com>
Cc: Ingo Molnar <mingo@elte.hu>, Andrew Morton <akpm@linux-foundation.org>, Andi Kleen <ak@suse.de>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Fri, 18 Jan 2008, Mike Travis wrote:

 > I hadn't considered doing 32-bit NUMA changes as I didn't know if the
> NR_CPUS count would really be increased for the 32-bit architecture.
> I have been trying though not to break it. ;-)

32bit NUMA is tricky because ZONE_NORMAL memory is only available on node 
0. There have been thorny difficult to debug issues in the past...


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
