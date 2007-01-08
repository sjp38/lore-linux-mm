Received: by ug-out-1314.google.com with SMTP id s2so5933173uge
        for <linux-mm@kvack.org>; Sun, 07 Jan 2007 22:47:48 -0800 (PST)
Message-ID: <eada2a070701072247w165f9beem6d24ec8e3325c6f3@mail.gmail.com>
Date: Sun, 7 Jan 2007 22:47:47 -0800
From: "Tim Pepper" <tpepper@gmail.com>
Subject: Re: [PATCH] Fix sparsemem on Cell (take 3)
In-Reply-To: <1168160307.6740.9.camel@localhost.localdomain>
MIME-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
References: <20061215165335.61D9F775@localhost.localdomain>
	 <200612182354.47685.arnd@arndb.de>
	 <1166483780.8648.26.camel@localhost.localdomain>
	 <200612190959.47344.arnd@arndb.de>
	 <1168045803.8945.14.camel@localhost.localdomain>
	 <1168059162.23226.1.camel@sinatra.austin.ibm.com>
	 <1168160307.6740.9.camel@localhost.localdomain>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Dave Hansen <haveblue@us.ibm.com>
Cc: John Rose <johnrose@austin.ibm.com>, Andrew Morton <akpm@osdl.org>, External List <linuxppc-dev@ozlabs.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, kmannth@us.ibm.com, lkml <linux-kernel@vger.kernel.org>, hch@infradead.org, linux-mm@kvack.org, Paul Mackerras <paulus@samba.org>, mkravetz@us.ibm.com, gone@us.ibm.com, Arnd Bergmann <arnd@arndb.de>
List-ID: <linux-mm.kvack.org>

On 1/7/07, Dave Hansen <haveblue@us.ibm.com> wrote:
> On Fri, 2007-01-05 at 22:52 -0600, John Rose wrote:
> > Could this break ia64, given that it uses memmap_init_zone()?
>
> You are right, I think it does.

Boot tested OK on ia64 with this latest version of the patch.

(forgot to click plain text on gmail the first time..sorry if you got
html mail or repeat)


Tim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
