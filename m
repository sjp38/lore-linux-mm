Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx153.postini.com [74.125.245.153])
	by kanga.kvack.org (Postfix) with SMTP id C278A6B004D
	for <linux-mm@kvack.org>; Thu,  8 Mar 2012 20:26:04 -0500 (EST)
Received: from m1.gw.fujitsu.co.jp (unknown [10.0.50.71])
	by fgwmail5.fujitsu.co.jp (Postfix) with ESMTP id 3FCE93EE0C3
	for <linux-mm@kvack.org>; Fri,  9 Mar 2012 10:26:03 +0900 (JST)
Received: from smail (m1 [127.0.0.1])
	by outgoing.m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 2749545DE56
	for <linux-mm@kvack.org>; Fri,  9 Mar 2012 10:26:03 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (s1.gw.fujitsu.co.jp [10.0.50.91])
	by m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 0F25545DE55
	for <linux-mm@kvack.org>; Fri,  9 Mar 2012 10:26:03 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 0049D1DB804E
	for <linux-mm@kvack.org>; Fri,  9 Mar 2012 10:26:03 +0900 (JST)
Received: from m107.s.css.fujitsu.com (m107.s.css.fujitsu.com [10.240.81.147])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id AE8B11DB8048
	for <linux-mm@kvack.org>; Fri,  9 Mar 2012 10:26:02 +0900 (JST)
Date: Fri, 9 Mar 2012 10:24:31 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH] memcg: Free spare array to avoid memory leak
Message-Id: <20120309102431.5a8a1c3d.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <4F588DF5.60300@gmail.com>
References: <1331036004-7550-1-git-send-email-handai.szj@taobao.com>
	<20120307230819.GA10238@shutemov.name>
	<4F581554.6020801@gmail.com>
	<20120308103510.GA12897@shutemov.name>
	<4F588DF5.60300@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sha Zhengju <handai.szj@gmail.com>
Cc: "Kirill A. Shutemov" <kirill@shutemov.name>, linux-mm@kvack.org, cgroups@vger.kernel.org, Sha Zhengju <handai.szj@taobao.com>

On Thu, 08 Mar 2012 18:46:13 +0800
Sha Zhengju <handai.szj@gmail.com> wrote:

> On 03/08/2012 06:35 PM, Kirill A. Shutemov wrote:
> > On Thu, Mar 08, 2012 at 10:11:32AM +0800, Sha Zhengju wrote:
> >> On 03/08/2012 07:08 AM, Kirill A. Shutemov wrote:
> >>> On Tue, Mar 06, 2012 at 08:13:24PM +0800, Sha Zhengju wrote:
> >>>> From: Sha Zhengju<handai.szj@taobao.com>
> >>>>
> >>>> When the last event is unregistered, there is no need to keep the spare
> >>>> array anymore. So free it to avoid memory leak.
> >>> It's not a leak. It will be freed on next event register.
> >>
> >> Yeah, I noticed that. But what if it is just the last one and no more
> >> event registering ?
> > See my question below. ;)
> >
> >>> Yeah, we don't have to keep spare if primary is empty. But is it worth to
> >>> make code more complicated to save few bytes of memory?
> >>>
> If we unregister the last event and *don't* register a new event anymore,
> the primary is freed but the spare is still kept which has no chance to
> free.
> 
> IMHO, it's obvious not a problem of saving bytes but *memory leak*.
> 

IMHO, it's cached. It will be freed when a memcg is destroyed.

Thanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
