From: "ismail (cartman) donmez" <kde@myrealbox.com>
Subject: Re: 2.6.0-test2-mm1
Date: Tue, 29 Jul 2003 08:33:02 +0300
References: <20030727233716.56fb68d2.akpm@osdl.org>
In-Reply-To: <20030727233716.56fb68d2.akpm@osdl.org>
MIME-Version: 1.0
Content-Disposition: inline
Content-Type: text/plain;
  =?ISO-8859-1?Q?charset=3D"=FDso-8859-1"?=
Content-Transfer-Encoding: 7bit
Message-Id: <200307290833.02848.kde@myrealbox.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@osdl.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hi,

Some things I noticed:

1- Seems like you missed out framebuffer patch ( there was a little s/</<= 
patch ) so we don't see any penguin at startup anymore.

2- Con's patch makes KDE's sound daemon skip ( aRts ) when using Juk ( KDE 
JukeBox ) [ to skip just minimize/maximize any window fast ] . Seems like 
problem is at aRts decoding as mplayer -ao arts works fine without skips.

Regards,
/ismail
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
