Date: Wed, 7 May 2003 23:54:30 +0200
Subject: Re: 2.5.69-mm2 Kernel panic, possibly network related
Message-ID: <20030507215430.GA1109@hh.idb.hist.no>
References: <3EB8E4CC.8010409@aitel.hist.no> <20030507.025626.10317747.davem@redhat.com> <20030507144100.GD8978@holomorphy.com> <20030507.064010.42794250.davem@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20030507.064010.42794250.davem@redhat.com>
From: Helge Hafting <helgehaf@aitel.hist.no>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "David S. Miller" <davem@redhat.com>
Cc: wli@holomorphy.com, helgehaf@aitel.hist.no, linux-kernel@vger.kernel.org, linux-mm@kvack.org, akpm@digeo.com
List-ID: <linux-mm.kvack.org>

On Wed, May 07, 2003 at 06:40:10AM -0700, David S. Miller wrote:
>    From: William Lee Irwin III <wli@holomorphy.com>
>    Date: Wed, 7 May 2003 07:41:00 -0700
>    
>    In another thread, you mentioned that a certain netfilter cset had
>    issues; I think it might be good to add that as a second possible
>    cause.
> 
> Good point, Helge what netfilter stuff do you have in use?
> Are you doing NAT?

I have compiled in almost everything from netfilter, except
from "Amanda backup protocol support" and "NAT of local connections"

I also have ipv6 compiled, but no ipv6-netfilter.

I don't do any NAT.  I used to have some firewall rules, but not currently
as some previous dev-kernel broke on that.  So I have iptables
with no rules, just an ACCEPT policy for everything. I do no
routing either, only one network card is used.

Helge Hafting

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
