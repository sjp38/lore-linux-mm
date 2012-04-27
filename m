Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx195.postini.com [74.125.245.195])
	by kanga.kvack.org (Postfix) with SMTP id D03486B004A
	for <linux-mm@kvack.org>; Fri, 27 Apr 2012 09:55:40 -0400 (EDT)
Message-ID: <4F9AA54E.6050007@redhat.com>
Date: Fri, 27 Apr 2012 09:55:26 -0400
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [RFC][PATCH] avoid swapping out with swappiness==0
References: <20120424082019.GA18395@alpha.arachsys.com> <alpine.DEB.2.00.1204260948520.16059@router.home>
In-Reply-To: <alpine.DEB.2.00.1204260948520.16059@router.home>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>
Cc: Richard Davies <richard@arachsys.com>, Satoru Moriya <satoru.moriya@hds.com>, KOSAKI Motohiro <kosaki.motohiro@gmail.com>, Jerome Marchand <jmarchan@redhat.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, "jweiner@redhat.com" <jweiner@redhat.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "lwoodman@redhat.com" <lwoodman@redhat.com>, "shaohua.li@intel.com" <shaohua.li@intel.com>, "dle-develop@lists.sourceforge.net" <dle-develop@lists.sourceforge.net>, Seiji Aguchi <seiji.aguchi@hds.com>, Minchan Kim <minchan.kim@gmail.com>

On 04/26/2012 10:50 AM, Christoph Lameter wrote:
> On Tue, 24 Apr 2012, Richard Davies wrote:
>
>> I strongly believe that Linux should have a way to turn off swapping unless
>> absolutely necessary. This means that users like us can run with swap
>> present for emergency use, rather than having to disable it because of the
>> side effects.
>
> Agree. And this ooperation mode should be the default behavior given that
> swapping is a very slow and tedious process these days.

I believe that is a bad idea.

With cgroups, the situation is a whole lot less obvious than with
the simple test done in this patch.  Lets see how the 3.4 code
behaves, and if we need any additional changes to reduce swapping
and step up reclaiming of page cache...

-- 
All rights reversed

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
