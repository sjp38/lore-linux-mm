Subject: Re: NUMA is bust with CONFIG_PREEMPT=y
From: Robert Love <rml@tech9.net>
In-Reply-To: <384860000.1033595383@flay>
References: <3D9B6939.397DB9EA@digeo.com>  <384860000.1033595383@flay>
Content-Type: text/plain
Message-Id: <1033596139.27343.14.camel@phantasy>
Mime-Version: 1.0
Date: 02 Oct 2002 18:02:19 -0400
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "Martin J. Bligh" <mbligh@aracnet.com>
Cc: Andrew Morton <akpm@digeo.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Wed, 2002-10-02 at 17:49, Martin J. Bligh wrote:

> I'd favour the latter. It doesn't seem that useful on big machines like this,
> and adds significant complication ... anyone really want it on a NUMA box? If
> not, I'll make a patch to disable it for NUMA machines ...

I am not one of the 12 people in the world with a NUMA-Q, but I would
not like to see you disable kernel preemption.

I would really like to see it work on every architecture in every
configuration.  Is it that hard to make the requisite changes to fix it
up?

If nothing else, I think you guys can _infinitely_ benefit from the
atomicity checking infrastructure that is now in place.

Besides, why screw yourself over from the day when preemption is a
requirement? </semi-kidding> ;-)

just my two bits,

	Robert Love


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
