Date: Wed, 23 Oct 2002 16:10:07 -0500
From: Dave McCracken <dmccr@us.ibm.com>
Subject: Re: 2.5.44-mm3: X doesn't work
Message-ID: <210140000.1035407407@baldur.austin.ibm.com>
In-Reply-To: <200210231659.42064.tomlins@cam.org>
References: <20021023205808.0449836a.diegocg@teleline.es>
 <447940000.1035403802@flay> <200210231659.42064.tomlins@cam.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Ed Tomlinson <tomlins@cam.org>, "Martin J. Bligh" <mbligh@aracnet.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

--On Wednesday, October 23, 2002 16:59:41 -0400 Ed Tomlinson
<tomlins@cam.org> wrote:

> I have not tried the fourth choise.  In my case X has never worked when
> SHPTE is enabled - this has been true from the first versions of the
> patch.

Ok, I finally managed to get KDE 3 installed on my victim machine.  I put
together a .xinitrc that runs ksmserver.  It all came up just fine with
shpte turned on.

What other things should I set?  Do you have high memory?  PAE?  If so,
have you enabled highpte?  I'm assuming we're talking about ksmserver
3.0.4, right?

Dave McCracken

======================================================================
Dave McCracken          IBM Linux Base Kernel Team      1-512-838-3059
dmccr@us.ibm.com                                        T/L   678-3059

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
