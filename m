Content-Type: text/plain;
  charset="iso-8859-1"
From: Rudmer van Dijk <rudmer@legolas.dynup.net>
Reply-To: rudmer@legolas.dynup.net
Message-Id: <200304151128.2775@gandalf>
Subject: Re: 2.5.67-mm3
Date: Tue, 15 Apr 2003 11:38:55 +0200
References: <20030414015313.4f6333ad.akpm@digeo.com> <20030414181302.0da41360.akpm@digeo.com> <20030415013447.GA3592@gnuppy.monkey.org>
In-Reply-To: <20030415013447.GA3592@gnuppy.monkey.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "Bill Huey (Hui)" <billh@gnuppy.monkey.org>, Andrew Morton <akpm@digeo.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Tuesday 15 April 2003 03:34, Bill Huey (Hui) wrote:
> On Mon, Apr 14, 2003 at 06:13:02PM -0700, Andrew Morton wrote:
> > Could be anything.   Does sysrq not work?
> > 
> > If not, please send me your .config.
> 
> It does it with elevator=deadline too. I'll see if I can get you better
> dump.

no problems here (running with anticipatory scheduling elevator), current 
uptime is 18h. 
the only problem I have is that kmod does not seem to work, modules has to be 
inserted manually... probably a problem with module-init-tools.

	Rudmer
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
