From: Aroop MP <aroop@poornam.com>
Subject: lsattr: Inappropriate ioctl for device While reading flags!!!
Date: Tue, 27 Jul 2004 07:41:43 +0530
References: <20040723190555.GB16956@sgi.com> <200407270729.45116.aroop@poornam.com> <20040727020338.GB23967@sgi.com>
In-Reply-To: <20040727020338.GB23967@sgi.com>
MIME-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Message-Id: <200407270741.44003.aroop@poornam.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Dimitri Sivanich <sivanich@sgi.com>, manfred@colorfullife.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, lse-tech@lists.sourceforge.net
List-ID: <linux-mm.kvack.org>

Hi,

Thanks for your quick reply. When i check lsattr of the file 
/usr/local/cpanel/3rdparty/etc/php.ini  i got the following error.
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Server[~]# lsattr /usr/local/cpanel/3rdparty/etc/php.ini
lsattr: Inappropriate ioctl for device While reading flags on 
/usr/local/cpanel/3rdparty/etc/php.ini
Server[~]#
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Please get back to me if you need any more  info. regarding this.

Thank You.

On Tuesday 27 Jul 2004 7:33 am, you wrote:
> On Tue, Jul 27, 2004 at 07:29:44AM +0530, Aroop MP wrote:
> > I have a simple doubt. Please answer it.
> > Why the error " Inappropriate ioctl for device While reading flags
> > ......................" is ocuring?. YOur replies will be greatly
> > appreciated.
>
> I have not seen this.  Can you elaborate?

-- 

 Regards, 
 Aroop M.P
 ---------------------------------------------------
 "NO MATTER WHERE YOU ARE IN THE WORLD,IF YOU HAVE DECIDED TO DO  SOMETHING 
DEEP FROM YOUR HEART YOU CAN DO IT. IT HAS ALWAYS BEEN THE   THOUGHT THAT 
MATTERS... "
 ---------------------------------------------------
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
