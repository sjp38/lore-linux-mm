From: "ismail (cartman) donmez" <kde@myrealbox.com>
Subject: Re: 2.5.73-mm1
Date: Tue, 24 Jun 2003 11:02:22 +0300
References: <20030623232908.036a1bd2.akpm@digeo.com> <200306241045.15886.kde@myrealbox.com> <20030624005720.06b2d3d0.akpm@digeo.com>
In-Reply-To: <20030624005720.06b2d3d0.akpm@digeo.com>
MIME-Version: 1.0
Content-Disposition: inline
Content-Type: text/plain;
  =?ISO-8859-1?Q?charset=3D"=FDso-8859-1"?=
Content-Transfer-Encoding: 7bit
Message-Id: <200306241102.22667.kde@myrealbox.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@digeo.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Tuesday 24 June 2003 10:57, Andrew Morton wrote:
> The configurable PAGE_OFFSET patch seems to confuse the build system
> sometimes.
>
> Do another `make oldconfig', that should flush it out.
Doing make menuconfig->exit->save fixed it. 

Regards,
/ismail
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
