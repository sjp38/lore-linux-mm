Date: Sun, 11 May 2003 23:42:03 -0700 (PDT)
Message-Id: <20030511.234203.57448687.davem@redhat.com>
Subject: Re: Slab corruption mm3 + davem fixes
From: "David S. Miller" <davem@redhat.com>
In-Reply-To: <200305120344.50347.tomlins@cam.org>
References: <20030511151506.172eee58.akpm@digeo.com>
	<1052692449.4471.4.camel@rth.ninka.net>
	<200305120344.50347.tomlins@cam.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: tomlins@cam.org
Cc: akpm@digeo.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, rusty@rustcorp.com.au, laforge@netfilter.org
List-ID: <linux-mm.kvack.org>

   On May 11, 2003 06:34 pm, David S. Miller wrote:
   > > > Yeah, more bugs in the NAT netfilter changes.  Debugging this one
   > > > patch is becomming a full time job :-(
   
   But you do it well...  Looks like this fixes the slab problems here with
   69-bk from Sunday am.
   
Thank you for testing.
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
