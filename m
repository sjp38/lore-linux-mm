From: Ed Tomlinson <tomlins@cam.org>
Subject: Re: 2.5.62-mm2
Date: Fri, 21 Feb 2003 20:48:09 -0500
References: <20030220234733.3d4c5e6d.akpm@digeo.com>
In-Reply-To: <20030220234733.3d4c5e6d.akpm@digeo.com>
MIME-Version: 1.0
Content-Disposition: inline
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Message-Id: <200302212048.09802.tomlins@cam.org>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@digeo.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On February 21, 2003 02:47 am, Andrew Morton wrote:
> So this tree has three elevators (apart from the no-op elevator).  You can
> select between them via the kernel boot commandline:
>
>         elevator=as
>         elevator=cfq
>         elevator=deadline

Has anyone been having problems booting with 'as'?  It hangs here at the point
root gets mounted readonly.  cfq works ok.



If this has already been reported sorry - mail is lagging here.

Ed Tomlinson

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org">aart@kvack.org</a>
