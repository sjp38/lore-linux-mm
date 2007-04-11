Received: by ug-out-1314.google.com with SMTP id s2so72584uge
        for <linux-mm@kvack.org>; Wed, 11 Apr 2007 02:53:49 -0700 (PDT)
Message-ID: <ac8af0be0704110253p74de6197p1df6a5b99585709c@mail.gmail.com>
Date: Wed, 11 Apr 2007 17:53:49 +0800
From: "Zhao Forrest" <forrest.zhao@gmail.com>
Subject: Re: Why kmem_cache_free occupy CPU for more than 10 seconds?
In-Reply-To: <84144f020704102353r7dcc3538u2e34237d3496630e@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
References: <ac8af0be0704102317q50fe72b1m9e4825a769a63963@mail.gmail.com>
	 <84144f020704102353r7dcc3538u2e34237d3496630e@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Pekka Enberg <penberg@cs.helsinki.fi>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

I got some new information:
Before soft lockup message is out, we have:
[root@nsgsh-dhcp-149 home]# cat /proc/slabinfo |grep buffer_head
buffer_head       10927942 10942560    120   32    1 : tunables   32
16    8 : slabdata 341955 341955      6 : globalstat 37602996 11589379
1174373    6                              0    1 6918 12166031 1013708
: cpustat 35254590 2350698 13610965 907286

Then after buffer_head is freed, we have:
[root@nsgsh-dhcp-149 home]# cat /proc/slabinfo |grep buffer_head
buffer_head         9542  36384    120   32    1 : tunables   32   16
  8 : slabdata   1137   1137    245 : globalstat 37602996 11589379
1174373    6                                  0    1 6983 20507478
1708818 : cpustat 35254625 2350704 16027174 1068367

Does this huge number of buffer_head cause the soft lockup?

Thanks,
Forrest

On 4/11/07, Pekka Enberg <penberg@cs.helsinki.fi> wrote:
> On 4/11/07, Zhao Forrest <forrest.zhao@gmail.com> wrote:
> > We're using RHEL5 with kernel version 2.6.18-8.el5.
> > When doing a stress test on raw device for about 3-4 hours, we found
> > the soft lockup message in dmesg.
> > I know we're not reporting the bug on the latest kernel, but does any
> > expert know if this is the known issue in old kernel? Or why
> > kmem_cache_free occupy CPU for more than 10 seconds?
>
> Sounds like slab corruption. CONFIG_DEBUG_SLAB should tell you more.
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
