From: Dave McCracken <dave.mccracken@oracle.com>
Subject: Re: pte_offset_map for ppc assumes HIGHPTE
Date: Wed, 25 Jul 2007 18:30:21 -0500
References: <acbcf3840707251516w301f834cj5f6a81a494d359ed@mail.gmail.com> <jewswodqcn.fsf@sykes.suse.de> <1185405765.5439.371.camel@localhost.localdomain>
In-Reply-To: <1185405765.5439.371.camel@localhost.localdomain>
MIME-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Message-Id: <200707251830.21944.dave.mccracken@oracle.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Cc: Andreas Schwab <schwab@suse.de>, Satya <satyakiran@gmail.com>, linuxppc-dev@ozlabs.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Wednesday 25 July 2007, Benjamin Herrenschmidt wrote:
> Depends... if you have CONFIG_HIGHMEM and not CONFIG_HIGHPTE, you are
> wasting time going through kmap_atomic unnecessarily no ? it will probably
> not do anything because the PTE page is in lowmem but still...

Probably not much time.  You still need to do the page to virtual translation, 
which kmap_atomic does for you.

Dave McCracken

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
