Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx198.postini.com [74.125.245.198])
	by kanga.kvack.org (Postfix) with SMTP id 5C6496B004A
	for <linux-mm@kvack.org>; Thu, 26 Apr 2012 11:36:59 -0400 (EDT)
Received: by dadq36 with SMTP id q36so1943199dad.8
        for <linux-mm@kvack.org>; Thu, 26 Apr 2012 08:36:58 -0700 (PDT)
Message-ID: <4F996BA6.9010900@gmail.com>
Date: Thu, 26 Apr 2012 11:37:10 -0400
From: KOSAKI Motohiro <kosaki.motohiro@gmail.com>
MIME-Version: 1.0
Subject: Re: [RFC][PATCH] avoid swapping out with swappiness==0
References: <20120424082019.GA18395@alpha.arachsys.com> <alpine.DEB.2.00.1204260948520.16059@router.home>
In-Reply-To: <alpine.DEB.2.00.1204260948520.16059@router.home>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>
Cc: Richard Davies <richard@arachsys.com>, Satoru Moriya <satoru.moriya@hds.com>, KOSAKI Motohiro <kosaki.motohiro@gmail.com>, Jerome Marchand <jmarchan@redhat.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, "jweiner@redhat.com" <jweiner@redhat.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "riel@redhat.com" <riel@redhat.com>, "lwoodman@redhat.com" <lwoodman@redhat.com>, "shaohua.li@intel.com" <shaohua.li@intel.com>, "dle-develop@lists.sourceforge.net" <dle-develop@lists.sourceforge.net>, Seiji Aguchi <seiji.aguchi@hds.com>, Minchan Kim <minchan.kim@gmail.com>

(4/26/12 10:50 AM), Christoph Lameter wrote:
> On Tue, 24 Apr 2012, Richard Davies wrote:
>
>> I strongly believe that Linux should have a way to turn off swapping unless
>> absolutely necessary. This means that users like us can run with swap
>> present for emergency use, rather than having to disable it because of the
>> side effects.
>
> Agree. And this ooperation mode should be the default behavior given that
> swapping is a very slow and tedious process these days.

Even though current patch is not optimal, I don't disagree this opinion. Can
you please explain your use case? Why don't you use swapoff?

Off topic: I hope linux is going to aim good swap clustered io in future. Especially
when using THP, 4k size io is not really good.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
