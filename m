Date: Wed, 7 May 2003 18:38:54 -0700
From: William Lee Irwin III <wli@holomorphy.com>
Subject: Re: 2.5.69-mm2 Kernel panic, possibly network related
Message-ID: <20030508013854.GW8931@holomorphy.com>
References: <3EB8E4CC.8010409@aitel.hist.no> <20030507.025626.10317747.davem@redhat.com> <20030507144100.GD8978@holomorphy.com> <20030507.064010.42794250.davem@redhat.com> <20030507215430.GA1109@hh.idb.hist.no>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20030507215430.GA1109@hh.idb.hist.no>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Helge Hafting <helgehaf@aitel.hist.no>
Cc: "David S. Miller" <davem@redhat.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, akpm@digeo.com
List-ID: <linux-mm.kvack.org>

On Wed, May 07, 2003 at 06:40:10AM -0700, David S. Miller wrote:
>> Good point, Helge what netfilter stuff do you have in use?
>> Are you doing NAT?

On Wed, May 07, 2003 at 11:54:30PM +0200, Helge Hafting wrote:
> I have compiled in almost everything from netfilter, except
> from "Amanda backup protocol support" and "NAT of local connections"
> I also have ipv6 compiled, but no ipv6-netfilter.
> I don't do any NAT.  I used to have some firewall rules, but not currently
> as some previous dev-kernel broke on that.  So I have iptables
> with no rules, just an ACCEPT policy for everything. I do no
> routing either, only one network card is used.

Can you try one kernel with the netfilter cset backed out, and another
with the re-slabification patch backed out? (But not with both backed
out simultaneously).

Thanks.


-- wli
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
