Date: Mon, 14 Jan 2008 11:16:56 -0800 (PST)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [PATCH 01/10] x86: Change size of APICIDs from u8 to u16
In-Reply-To: <478BAAD5.1090500@sgi.com>
Message-ID: <Pine.LNX.4.64.0801141116160.7891@schroedinger.engr.sgi.com>
References: <20080113183453.973425000@sgi.com> <20080113183454.155968000@sgi.com>
 <Pine.LNX.4.64.0801141908370.24893@fbirervta.pbzchgretzou.qr>
 <478BAAD5.1090500@sgi.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Mike Travis <travis@sgi.com>
Cc: Jan Engelhardt <jengelh@computergmbh.de>, Andrew Morton <akpm@linux-foundation.org>, Andi Kleen <ak@suse.de>, mingo@elte.hu, Jack Steiner <steiner@sgi.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Mon, 14 Jan 2008, Mike Travis wrote:

> I see the mistake in the node array.  But AFAICT, pxm is the proximity
> between nodes and cannot be expressed as greater than the number of
> nodes, yes?  (Or can it be arbitrarily expressed where 32 bits is
> necessary?)  I ask this because the real node_to_pxm_map is already
> 32 bits.

Well I think local variables that contain a node can be int without a 
problem because that is what the core used to store node ids.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
