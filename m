Message-ID: <47CE5D41.3010506@cn.fujitsu.com>
Date: Wed, 05 Mar 2008 17:43:45 +0900
From: Li Zefan <lizf@cn.fujitsu.com>
MIME-Version: 1.0
Subject: Re: [PATCH 1/2] Cpuset hardwall flag:  Switch cpusets to use the
 bulk cgroup_add_files() API
References: <20080305075237.608599000@menage.corp.google.com> <20080305080000.270536000@menage.corp.google.com>
In-Reply-To: <20080305080000.270536000@menage.corp.google.com>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: menage@google.com
Cc: pj@sgi.com, akpm@linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

menage@google.com wrote:
> This change tidies up the cpusets control file definitions, and
> reduces the amount of boilerplate required to add/change control files
> in the future.
> 
> Signed-off-by: Paul Menage <menage@google.com>
> 

Actually I've done this cleanup but don't have time to post the
patch. :)

Reviewed-by: Li Zefan <lizf@cn.fujitsu.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
