Content-Type: text/plain;
  charset="iso-8859-1"
From: Daniel Phillips <phillips@arcor.de>
Subject: Re: [PATCH] per-zone kswapd process
Date: Mon, 16 Sep 2002 07:44:30 +0200
References: <3D815C8C.4050000@us.ibm.com> <3D81643C.4C4E862C@digeo.com> <20020913045938.GG2179@holomorphy.com>
In-Reply-To: <20020913045938.GG2179@holomorphy.com>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
Message-Id: <E17qogR-0000HR-00@starship>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: William Lee Irwin III <wli@holomorphy.com>, Andrew Morton <akpm@digeo.com>
Cc: Dave Hansen <haveblue@us.ibm.com>, "Martin J. Bligh" <Martin.Bligh@us.ibm.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Friday 13 September 2002 06:59, William Lee Irwin III wrote:
> On Thu, Sep 12, 2002 at 09:06:20PM -0700, Andrew Morton wrote:
> > I still don't see why it's per zone and not per node.  It seems strange
> > that a wee little laptop would be running two kswapds?
> > kswapd can get a ton of work done in the development VM and one per
> > node would, I expect, suffice?
> 
> Machines without observable NUMA effects can benefit from it if it's
> per-zone.

How?

-- 
Daniel
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
