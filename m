Content-Type: text/plain;
  charset="iso-8859-1"
From: Ed Tomlinson <tomlins@cam.org>
Subject: Re: [PATCH 2.5.41-mm1] new snapshot of shared page tables
Date: Sat, 12 Oct 2002 10:19:58 -0400
References: <228900000.1034197657@baldur.austin.ibm.com> <20021010031928.GT12432@holomorphy.com> <200210101829.40432.tomlins@cam.org>
In-Reply-To: <200210101829.40432.tomlins@cam.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
Message-Id: <200210121019.58055.tomlins@cam.org>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: William Lee Irwin III <wli@holomorphy.com>
Cc: Dave McCracken <dmccr@us.ibm.com>, Linux Memory Management <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On October 10, 2002 06:29 pm, Ed Tomlinson wrote:
> On October 9, 2002 11:19 pm, William Lee Irwin III wrote:
> > On Wed, Oct 09, 2002 at 11:04:47PM -0400, Ed Tomlinson wrote:
> > > After realizing (thanks Dave) that kmail 3.03 has a bug saving
> > > multipart/mixed mime messages, I was able to use uudeview to extract
> > > a clean patch, and build kernel which boot fine.  Thats the good news.
> > > When I try to start kde 3.03 on an up to date debian sid (X 4.2 etc)
> > > kde fails to start. It complains that ksmserver cannot be started.
> > > Same setup works with 41-mm1.
> > > Know this is not a meaty report.  With X4.2 I have not yet figgered
> > > out how to get more debug messages (the log from xstart is anemic)
> > > nor is there anything in messages, kern.log or on the serial console.
> > > The box is a K6-III 400 on a via MVP3 chipset.
> > > What other info can I gather?
> > > Ed Tomlinson
> >
> > Could you strace ksmserver on a working and non-working console and
> > (privately) send (probably large) logs to dmc & me? Please use
> > strace -f -ff or some equivalent that follows children.
>
> Hope the straces helped...
>
> I tried again this evening with mm2 plus shpte-2.5.41-mm2-1.diff and
> shpte-2.5.41-mm2-2.diff and still get the same error.

And again with 2.5.42-mm2 - still no joy.  Errror looks the same here.
Do you want another set of traces?

Ed 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
