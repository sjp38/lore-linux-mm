Date: Tue, 8 Jan 2008 11:04:01 -0800 (PST)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [PATCH 00/10] percpu: Per cpu code simplification V3
In-Reply-To: <20080108090702.GB27671@elte.hu>
Message-ID: <Pine.LNX.4.64.0801081102450.2228@schroedinger.engr.sgi.com>
References: <20080108021142.585467000@sgi.com> <20080108090702.GB27671@elte.hu>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Ingo Molnar <mingo@elte.hu>
Cc: travis@sgi.com, Andrew Morton <akpm@linux-foundation.org>, Andi Kleen <ak@suse.de>, Jack Steiner <steiner@sgi.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Tue, 8 Jan 2008, Ingo Molnar wrote:

> i had the patch below for v2, it's still needed (because i didnt apply 
> the s390/etc. bits), right?

Well the patch really should go through mm because it is a change that 
covers multiple arches. I think testing with this is fine. I think Mike 
has diffed this against Linus tree so this works but will now conflict 
with the modcopy patch already in mm.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
