Subject: Re: [patch 0/6] Strong Access Ordering page attributes for POWER7
From: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Reply-To: benh@kernel.crashing.org
In-Reply-To: <48728942.6050007@austin.ibm.com>
References: <20080618223254.966080905@linux.vnet.ibm.com>
	 <1215128392.7960.7.camel@pasglop>
	 <1215439540.16098.15.camel@norville.austin.ibm.com>
	 <48728942.6050007@austin.ibm.com>
Content-Type: text/plain
Date: Tue, 08 Jul 2008 08:27:57 +1000
Message-Id: <1215469677.8970.148.camel@pasglop>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Joel Schopp <jschopp@austin.ibm.com>
Cc: Dave Kleikamp <shaggy@linux.vnet.ibm.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, Paul Mackerras <paulus@au1.ibm.com>, Linuxppc-dev@ozlabs.org
List-ID: <linux-mm.kvack.org>

On Mon, 2008-07-07 at 16:23 -0500, Joel Schopp wrote:
> >> We haven't defined a user-visible feature bit (and besides, we're really
> >> getting short on these...). This is becoming a bit of concern btw (the
> >> running out of bits). Maybe we should start defining an AT_HWCAP2 for
> >> powerpc and get libc updated to pick it up ?
> >>     
> >
> > Joel,
> > Any thoughts?
> Is it a required or optional feature of the 2.06 architecture spec?  If it's required you could just use that.  It doesn't solve the problem more generically if other archs decide to implement it though.

And then we start having to expose 2.06S vs. 2.06E .. nah.

I think for now, for SAO, the idea that one can "try" and if -EINVAL,
try again without might work fine.

Cheers,
Ben.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
