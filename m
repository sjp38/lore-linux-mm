Date: Wed, 22 Aug 2007 13:09:13 +0200
From: Paolo Ornati <ornati@fastwebnet.it>
Subject: Re: huge improvement with per-device dirty throttling
Message-ID: <20070822130913.643c39be@localhost>
In-Reply-To: <p733aybzv6e.fsf@bingen.suse.de>
References: <1187764638.6869.17.camel@hannibal>
	<p733aybzv6e.fsf@bingen.suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andi Kleen <andi@firstfloor.org>
Cc: "Jeffrey W. Baker" <jwbaker@acm.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On 22 Aug 2007 13:05:13 +0200
Andi Kleen <andi@firstfloor.org> wrote:

> "Jeffrey W. Baker" <jwbaker@acm.org> writes:
> > 
> > My system is a Core 2 Duo, 2GB, single SATA disk.  
> 
> Hmm, I thought the patch was only supposed to make a real difference
> if you have multiple devices? But you only got a single disk.  

No, there's also:
[PATCH 22/23] mm: dirty balancing for tasks

:)

-- 
	Paolo Ornati
	Linux 2.6.23-rc3-g2a677896-dirty on x86_64

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
