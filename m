From: Ed Tomlinson <tomlins@cam.org>
Subject: Re: 2.5.61-mm1
Date: Sat, 15 Feb 2003 09:29:51 -0500
References: <20030214231356.59e2ef51.akpm@digeo.com>
In-Reply-To: <20030214231356.59e2ef51.akpm@digeo.com>
MIME-Version: 1.0
Content-Disposition: inline
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Message-Id: <200302150929.51856.tomlins@cam.org>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On February 15, 2003 02:13 am, Andrew Morton wrote:
>   Turns out that some parts of KDE (kmail, at least) were indeed using this
>   hint, and it triggers a nasty bug in (at least) kmail: it is reading the
>   same 128k of the file again and again and again.  It runs like a dog.
>   Ed Tomlinson upgraded his KDE/kmail version and this problem went away.

The versions of kmail involved were 3.04, which manifests the bug when switching
between folders with lots of entries (10,000+).  The kmail in kde 3.1 does not
have this problem.

Ed Tomlinson

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org">aart@kvack.org</a>
