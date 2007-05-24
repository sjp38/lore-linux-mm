Received: from zps76.corp.google.com (zps76.corp.google.com [172.25.146.76])
	by smtp-out.google.com with ESMTP id l4O7dQu0005732
	for <linux-mm@kvack.org>; Thu, 24 May 2007 00:39:26 -0700
Received: from ug-out-1314.google.com (ugdj40.prod.google.com [10.66.136.40])
	by zps76.corp.google.com with ESMTP id l4O7dMoG023173
	for <linux-mm@kvack.org>; Thu, 24 May 2007 00:39:23 -0700
Received: by ug-out-1314.google.com with SMTP id j40so707667ugd
        for <linux-mm@kvack.org>; Thu, 24 May 2007 00:39:22 -0700 (PDT)
Message-ID: <6599ad830705240039p10574207maca62b8c44825db7@mail.gmail.com>
Date: Thu, 24 May 2007 00:39:21 -0700
From: "Paul Menage" <menage@google.com>
Subject: Re: RSS controller v2 Test results (lmbench )
In-Reply-To: <4655407A.4090104@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
References: <464C95D4.7070806@linux.vnet.ibm.com>
	 <20070517112357.7adc4763.akpm@linux-foundation.org>
	 <4651B4BF.9040608@sw.ru> <4655407A.4090104@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: balbir@linux.vnet.ibm.com
Cc: Kirill Korotaev <dev@sw.ru>, Andrew Morton <akpm@linux-foundation.org>, Pavel Emelianov <xemul@sw.ru>, devel@openvz.org, Linux Containers <containers@lists.osdl.org>, linux kernel mailing list <linux-kernel@vger.kernel.org>, Linux Memory Management List <linux-mm@kvack.org>, Vaidyanathan Srinivasan <svaidy@linux.vnet.ibm.com>, "Eric W. Biederman" <ebiederm@xmission.com>, Herbert Poetzl <herbert@13thfloor.at>
List-ID: <linux-mm.kvack.org>

On 5/24/07, Balbir Singh <balbir@linux.vnet.ibm.com> wrote:
> Kirill Korotaev wrote:
> >> Where do we stand on all of this now anyway?  I was thinking of getting Paul's
> >> changes into -mm soon, see what sort of calamities that brings about.
> > I think we can merge Paul's patches with *interfaces* and then switch to
> > developing/reviewing/commiting resource subsytems.
> > RSS control had good feedback so far from a number of people
> > and is a first candidate imho.
> >
>
> Yes, I completely agree!
>

I'm just finishing up the latest version of my container patches -
hopefully sending them out tomorrow.

Paul

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
