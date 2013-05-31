Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx180.postini.com [74.125.245.180])
	by kanga.kvack.org (Postfix) with SMTP id A53CE6B0033
	for <linux-mm@kvack.org>; Fri, 31 May 2013 00:31:20 -0400 (EDT)
Received: by mail-pb0-f45.google.com with SMTP id mc17so1546993pbc.18
        for <linux-mm@kvack.org>; Thu, 30 May 2013 21:31:19 -0700 (PDT)
Message-ID: <51A82793.4080204@gmail.com>
Date: Fri, 31 May 2013 12:31:15 +0800
From: Jiang Liu <liuj97@gmail.com>
MIME-Version: 1.0
Subject: Re: [PATCH v8, part3 06/14] mm, acornfb: use free_reserved_area()
 to simplify code
References: <1369575522-26405-1-git-send-email-jiang.liu@huawei.com> <1369575522-26405-7-git-send-email-jiang.liu@huawei.com> <20130530145844.902b3a947c1f7430c1c2ecf5@linux-foundation.org>
In-Reply-To: <20130530145844.902b3a947c1f7430c1c2ecf5@linux-foundation.org>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Jiang Liu <jiang.liu@huawei.com>, David Rientjes <rientjes@google.com>, Wen Congyang <wency@cn.fujitsu.com>, Mel Gorman <mgorman@suse.de>, Minchan Kim <minchan@kernel.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Michal Hocko <mhocko@suse.cz>, James Bottomley <james.bottomley@hansenpartnership.com>, Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>, David Howells <dhowells@redhat.com>, Mark Salter <msalter@redhat.com>, Jianguo Wu <wujianguo@huawei.com>, linux-mm@kvack.org, linux-arch@vger.kernel.org, linux-kernel@vger.kernel.org, Florian Tobias Schandinat <florianschandinat@gmx.de>, linux-fbdev@vger.kernel.org

On Fri 31 May 2013 05:58:44 AM CST, Andrew Morton wrote:
> On Sun, 26 May 2013 21:38:34 +0800 Jiang Liu <liuj97@gmail.com> wrote:
>
>> Use common help function free_reserved_area() to simplify code.
>
> http://ozlabs.org/~akpm/mmots/broken-out/drivers-video-acornfbc-remove-dead-code.patch
> removes all the code which your patch alters.
Thanks Andrew, please just drop that patch.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
