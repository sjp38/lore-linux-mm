From: Ed Tomlinson <edt@aei.ca>
Subject: Re: 2.6.2-rc1-mm2
Date: Fri, 23 Jan 2004 19:46:55 -0500
References: <20040123013740.58a6c1f9.akpm@osdl.org> <200401231012.56686.edt@aei.ca> <20040123104300.401bf385.akpm@osdl.org>
In-Reply-To: <20040123104300.401bf385.akpm@osdl.org>
MIME-Version: 1.0
Content-Disposition: inline
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Message-Id: <200401231946.55379.edt@aei.ca>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-kernel@vger.kernel.org
Cc: Andrew Morton <akpm@osdl.org>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On January 23, 2004 01:43 pm, Andrew Morton wrote:
> Ed Tomlinson <edt@aei.ca> wrote:
> > Hi,
> >
> > This fails to boot here.  Config is 2-rc1 updated with oldconfig.  It
> > seems that it cannot find root.
>
> That's odd.

It turned out to be a distcc problem.  I rebuilt locally and it booting ok
now...

Ed
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
