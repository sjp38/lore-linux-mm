Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f41.google.com (mail-lf0-f41.google.com [209.85.215.41])
	by kanga.kvack.org (Postfix) with ESMTP id D529B82F99
	for <linux-mm@kvack.org>; Thu, 24 Dec 2015 08:14:54 -0500 (EST)
Received: by mail-lf0-f41.google.com with SMTP id y184so162550456lfc.1
        for <linux-mm@kvack.org>; Thu, 24 Dec 2015 05:14:54 -0800 (PST)
Received: from n26.netmark.pl (n26.netmark.pl. [94.124.9.61])
        by mx.google.com with ESMTPS id vs1si26564684lbb.129.2015.12.24.05.14.52
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 24 Dec 2015 05:14:53 -0800 (PST)
Date: Thu, 24 Dec 2015 14:14:44 +0100
From: Marcin Szewczyk <Marcin.Szewczyk@wodny.org>
Subject: Re: OOM killer kicks in after minutes or never
Message-ID: <20151224131444.GA3272@orkisz>
References: <20151221123557.GE3060@orkisz>
 <567B9042.9010105@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <567B9042.9010105@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: linux-kernel@vger.kernel.org, Linux-MM <linux-mm@kvack.org>, Michal Hocko <mhocko@suse.cz>, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, David Rientjes <rientjes@google.com>

On Thu, Dec 24, 2015 at 07:27:14AM +0100, Vlastimil Babka wrote:
> +CC so this doesn't get lost
> 
> On 21.12.2015 13:35, Marcin Szewczyk wrote:
> > In 2010 I noticed that viewing many GIFs in a row using gpicview renders
> > my Linux unresponsive. There is very little I can do in such a
> > situation. Rarely after some minutes the OOM killer kicks in and saves
> > the day. Nevertheless, usually I end up using Alt+SysRq+B.

Hi,

I thought that due to high throughput of the linux-kernel mailing list
my email will not get a reply if it didn't happen in a day so I allowed
myself to write another email to linux-mm as well as it was suggested to
me on #debian-kernel.

The email is here:
Subject: Exhausting memory makes the system unresponsive but doesn't
  invoke OOM killer
Message-ID: <20151223143109.GC3519@orkisz>
http://marc.info/?t=145088116000002&r=1&w=2

I have also updated the description in the repository:
https://github.com/wodny/crasher

Contrary to my original suspicion the OOM killer doesn't need much time
to clean up, it just isn't invoked. Johannes Weiner explained the
probable cause to me in a response in the linux-mm thread.


-- 
Marcin Szewczyk                       http://wodny.org
mailto:Marcin.Szewczyk@wodny.borg  <- remove b / usuA? b
xmpp:wodny@ubuntu.pl                  xmpp:wodny@jabster.pl

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
