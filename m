Date: Wed, 29 Jan 2003 16:30:34 -0800 (PST)
Message-Id: <20030129.163034.130834202.davem@redhat.com>
Subject: Re: Linus rollup
From: "David S. Miller" <davem@redhat.com>
In-Reply-To: <20030129151206.269290ff.akpm@digeo.com>
References: <20030129022617.62800a6e.akpm@digeo.com>
	<1043879752.10150.387.camel@dell_ss3.pdx.osdl.net>
	<20030129151206.269290ff.akpm@digeo.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: akpm@digeo.com
Cc: shemminger@osdl.org, rmk@arm.linux.org.uk, ak@muc.de, davidm@napali.hpl.hp.com, anton@samba.org, linux-mm@kvack.org, andrea@suse.de
List-ID: <linux-mm.kvack.org>

   
   But that would be a separate patch.  _all_ we are doing here is fixing and
   optimising the xtime_lock problems.  We should seek to do that with
   "equivalent transformations".

I agree, do this and arch people can tweak later.
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
