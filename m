Date: Wed, 5 Mar 2008 06:07:14 -0600
From: Paul Jackson <pj@sgi.com>
Subject: Re: [PATCH 1/2] Cpuset hardwall flag:  Switch cpusets to use the
 bulk cgroup_add_files() API
Message-Id: <20080305060714.f49f0d6a.pj@sgi.com>
In-Reply-To: <20080305080000.270536000@menage.corp.google.com>
References: <20080305075237.608599000@menage.corp.google.com>
	<20080305080000.270536000@menage.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: menage@google.com
Cc: akpm@linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Paul M wrote:
> This change tidies up the cpusets control file definitions,

Acked-by: Paul Jackson <pj@sgi.com>

-- 
                  I won't rest till it's the best ...
                  Programmer, Linux Scalability
                  Paul Jackson <pj@sgi.com> 1.940.382.4214

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
