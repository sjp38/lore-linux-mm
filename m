Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f69.google.com (mail-pg0-f69.google.com [74.125.83.69])
	by kanga.kvack.org (Postfix) with ESMTP id 59CFA6B025F
	for <linux-mm@kvack.org>; Fri, 24 Nov 2017 08:48:14 -0500 (EST)
Received: by mail-pg0-f69.google.com with SMTP id 190so21913236pgh.16
        for <linux-mm@kvack.org>; Fri, 24 Nov 2017 05:48:14 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id a14si18216585pgv.479.2017.11.24.05.48.13
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 24 Nov 2017 05:48:13 -0800 (PST)
Date: Fri, 24 Nov 2017 14:48:08 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: Re: Re: [PATCH 1/1] stackdepot: interface to check entries and
 size of stackdepot.
Message-ID: <20171124134808.ixyqzmzzyamja4ao@dhcp22.suse.cz>
References: <20171124124429.juonhyw4xbqc65u7@dhcp22.suse.cz>
 <CACT4Y+bF7TGFS+395kyzdw21M==ECgs+dCjV0e3Whkvm1_piDA@mail.gmail.com>
 <20171123162835.6prpgrz3qkdexx56@dhcp22.suse.cz>
 <1511347661-38083-1-git-send-email-maninder1.s@samsung.com>
 <20171124094108epcms5p396558828a365a876d61205b0fdb501fd@epcms5p3>
 <20171124095428.5ojzgfd24sy7zvhe@dhcp22.suse.cz>
 <20171124115707epcms5p4fa19970a325e87f08eadb1b1dc6f0701@epcms5p4>
 <CGME20171122105142epcas5p173b7205da12e1fc72e16ec74c49db665@epcms5p7>
 <20171124133025epcms5p7dc263c4a831552245e60193917a45b07@epcms5p7>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <20171124133025epcms5p7dc263c4a831552245e60193917a45b07@epcms5p7>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vaneet Narang <v.narang@samsung.com>
Cc: Dmitry Vyukov <dvyukov@google.com>, Maninder Singh <maninder1.s@samsung.com>, "kstewart@linuxfoundation.org" <kstewart@linuxfoundation.org>, "gregkh@linuxfoundation.org" <gregkh@linuxfoundation.org>, "pombredanne@nexb.com" <pombredanne@nexb.com>, "jpoimboe@redhat.com" <jpoimboe@redhat.com>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "vbabka@suse.cz" <vbabka@suse.cz>, "guptap@codeaurora.org" <guptap@codeaurora.org>, "vinmenon@codeaurora.org" <vinmenon@codeaurora.org>, AMIT SAHRAWAT <a.sahrawat@samsung.com>, PANKAJ MISHRA <pankaj.m@samsung.com>, Lalit Mohan Tripathi <lalit.mohan@samsung.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, kasan-dev <kasan-dev@googlegroups.com>

On Fri 24-11-17 13:30:25, Vaneet Narang wrote:
> Hi Michal,
> 
> >> We have been getting similar kind of such entries and eventually
> >> stackdepot reaches Max Cap. So we found this interface useful in debugging
> >> stackdepot issue so shared in community.
>  
> >Then use it for internal debugging and provide a code which would scale
> >better on smaller systems. We do not need this in the kernel IMHO. We do
> >not merge all the debugging patches we use for internal development.
> ` 
> Not just debugging but this information can also be used to profile and tune stack depot. 
> Getting count of stack entries would help in deciding hash table size and 
> page order used by stackdepot. 

How can you control that in runtime?

> For less entries, bigger hash table and higher page order slabs might not be required as 
> maintained by stackdepot. As i already mentioned smaller size hashtable can be choosen and 
> similarly lower order  pages can be used for slabs.
> 
> If you think its useful, we can share scalable patch to configure below two values based on 
> number of stack entries dynamically.

Exporting this data without having a way to control it is just not very
useful for upstream kernel. If you can come up with some dynamic tuning
then that might be interesting. But your patch doesn't seem useful
outside of the development enviroment AFAICS.

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
