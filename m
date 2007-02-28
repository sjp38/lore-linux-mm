From: "Rafael J. Wysocki" <rjw@sisk.pl>
Subject: Re: Remove page flags for software suspend
Date: Wed, 28 Feb 2007 18:13:04 +0100
References: <Pine.LNX.4.64.0702160212150.21862@schroedinger.engr.sgi.com> <20070228101403.GA8536@elf.ucw.cz> <Pine.LNX.4.64.0702280724540.16552@schroedinger.engr.sgi.com>
In-Reply-To: <Pine.LNX.4.64.0702280724540.16552@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Message-Id: <200702281813.04643.rjw@sisk.pl>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@engr.sgi.com>
Cc: Pavel Machek <pavel@ucw.cz>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Wednesday, 28 February 2007 16:25, Christoph Lameter wrote:
> On Wed, 28 Feb 2007, Pavel Machek wrote:
> 
> > I... actually do not like that patch. It adds code... at little or no
> > benefit.
> 
> We are looking into saving page flags since we are running out. The two 
> page flags used by software suspend are rarely needed and should be taken 
> out of the flags. If you can do it a different way then please do.

As I have already said for a couple of times, I think we can and I'm going to
do it, but right now I'm a bit busy with other things that I consider as more
urgent.

Greetings,
Rafael

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
