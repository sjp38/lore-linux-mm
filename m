Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx114.postini.com [74.125.245.114])
	by kanga.kvack.org (Postfix) with SMTP id 4713B6B0257
	for <linux-mm@kvack.org>; Fri, 22 Jun 2012 16:14:35 -0400 (EDT)
Received: by dakp5 with SMTP id p5so3415972dak.14
        for <linux-mm@kvack.org>; Fri, 22 Jun 2012 13:14:34 -0700 (PDT)
Date: Fri, 22 Jun 2012 13:14:29 -0700
From: Tejun Heo <tj@kernel.org>
Subject: Re: Early boot panic on machine with lots of memory
Message-ID: <20120622201429.GM4642@google.com>
References: <20120619041154.GA28651@shangw>
 <20120619212059.GJ32733@google.com>
 <20120619212618.GK32733@google.com>
 <CAE9FiQVECyRBie-kgBETmqxPaMx24kUt1W07qAqoGD4vNus5xQ@mail.gmail.com>
 <20120621201728.GB4642@google.com>
 <CAE9FiQXubmnKHjnqOxVeoJknJZFNuStCcW=1XC6jLE7eznkTmg@mail.gmail.com>
 <20120622185113.GK4642@google.com>
 <CAE9FiQVV+WOWywnanrP7nX-wai=aXmQS1Dcvt4PxJg5XWynC+Q@mail.gmail.com>
 <20120622192919.GL4642@google.com>
 <CAE9FiQWcxEcuCjCSoAucvAOZ-6FCqRvjPoYc+JRmxdL50nyNxg@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAE9FiQWcxEcuCjCSoAucvAOZ-6FCqRvjPoYc+JRmxdL50nyNxg@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Yinghai Lu <yinghai@kernel.org>
Cc: Gavin Shan <shangw@linux.vnet.ibm.com>, Sasha Levin <levinsasha928@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, David Miller <davem@davemloft.net>, hpa@linux.intel.com, linux-mm <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>

Hello, Yinghai.

On Fri, Jun 22, 2012 at 01:01:32PM -0700, Yinghai Lu wrote:
> using yhlu.kernel@gmail.com to get mail from the list and respond as
> yinghai@kernel.org.
> 
> gmail web client does not allow us to insert plain text.
> 
> if using standline thunderbird, that seems can not handle thousand mail.

I moved away from TB too (to gmail + mutt) but IIRC turning off
indexing made it mostly bearable for me.

> noticed now even Linus is attaching patch, so I assume that is ok
> because there is no othe good rway.

Yeah, it's okay but just not optimal.  I was wondering what changed.
My setup is pretty similar and in case you're intersted, here are some
tricks I've been using.

Thunderbird

 * In the Composition & Addressing tab of account setting, clear
   "Compose messages in HTML format".

 * Open Config Editor under Preferences -> Advanced -> General.
   * set mailnews.wraplength to 9999
   * set mailnews.send_plaintext_flowed to false

 * Install External Editor add-on and configure it to your favorite
   editor.

   http://globs.org/articles.php?pg=2&lng=en

   Ctrl-E launches the external editor.  The only caveat is that there
   seems to be a race condition and if the machine is under heavy load
   the extension occassinally loses the edited text, so it usually is a
   good idea to save a copy in a separate file before exiting the
   external editor.  It never happens on my desktop but happens on my
   laptop once in a blue moon.

Alternatively, you can use mutt for patch sending / processing.  With
caches turned on (set header_cache, set message_cachedir), it's
actually pretty useable w/ gmail.

-- 
tejun

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
