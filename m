From: Dmitry Torokhov <dtor_core@ameritech.net>
Subject: Re: keyboard troubles
Date: Sun, 19 Sep 2004 20:24:11 -0500
References: <1095401479.609.5.camel@localhost> <1095446128.4088.0.camel@localhost> <1095627236.22458.1.camel@localhost.localdomain>
In-Reply-To: <1095627236.22458.1.camel@localhost.localdomain>
MIME-Version: 1.0
Content-Disposition: inline
Content-Type: text/plain;
  charset="utf-8"
Content-Transfer-Encoding: 7bit
Message-Id: <200409192024.11525.dtor_core@ameritech.net>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org, Autar022@planet.nl
Cc: Dave Hansen <haveblue@us.ibm.com>
List-ID: <linux-mm.kvack.org>

On Sunday 19 September 2004 03:53 pm, Arvind Autar wrote:
> On Fri, 2004-09-17 at 20:35, Dave Hansen wrote:
> > On Thu, 2004-09-16 at 23:11, Arvind Autar wrote:
> > > When running "2.6.9-rc2-mm1" the keyboard seems to freeze after the
> > > boot. This problem didn't occur when using 2.6.9-rc1-mm1.When i I'm
> > > running a debian unstable/sid system. I have a qwerty  AT Translated Set
> > > 2 keyboard on isa0060/serio0.
> > 
> > Hmmm.  I'm seeing this in 2.6.8.1.  But, it's a new notebook, and I
> > wanted to blame the BIOS.  If you have a notebook, does suspending and
> > resuming it bring the keyboard back?  It does for me. 
> > 
> > -- Dave
> > 
> 
> Hi
> 
> I'm using 2.6.9-rc2-mm1 on my desktop pc. a keyboard that freezes during
> system boot is the last thing that I expected.
> 

Try booting with i8042.noacpi, helped in most cases with -rc2-mm1.

-- 
Dmitry
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
