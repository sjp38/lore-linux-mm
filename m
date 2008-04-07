From: "KOSAKI Motohiro" <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [-mm] Disable the memory controller by default
Date: Mon, 7 Apr 2008 21:12:37 +0900
Message-ID: <2f11576a0804070512g4421d4aar84fe659c21dda8a9@mail.gmail.com>
References: <20080407115137.24124.59692.sendpatchset@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1758404AbYDGMMt@vger.kernel.org>
In-Reply-To: <20080407115137.24124.59692.sendpatchset@localhost.localdomain>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
To: Balbir Singh <balbir@linux.vnet.ibm.com>
Cc: andi@firstfloor.org, Andrew Morton <akpm@linux-foundation.org>, YAMAMOTO Takashi <yamamoto@valinux.co.jp>, Paul Menage <menage@google.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Pavel Emelianov <xemul@openvz.org>, hugh@veritas.com, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
List-Id: linux-mm.kvack.org

Hi

>  diff -puN Documentation/kernel-parameters.txt~memory-controller-default-option-off Documentation/kernel-parameters.txt
>  --- linux-2.6.25-rc8/Documentation/kernel-parameters.txt~memory-controller-default-option-off   2008-04-07 16:38:25.000000000 +0530
>  +++ linux-2.6.25-rc8-balbir/Documentation/kernel-parameters.txt 2008-04-07 17:20:08.000000000 +0530
>  @@ -381,9 +381,10 @@ and is between 256 and 4096 characters.
>         ccw_timeout_log [S390]
>                         See Documentation/s390/CommonIO for details.
>
>  -       cgroup_disable= [KNL] Disable a particular controller
>  -                       Format: {name of the controller(s) to disable}
>  +       cgroup_toggle= [KNL] Toggle (enable/disable) a particular controller
>  +                       Format: {name of the controller(s) to enable/disable}
>                                 {Currently supported controllers - "memory"}
>  +                               {The memory controller is disabled by default}
>
>         checkreqprot    [SELINUX] Set initial checkreqprot flag value.
>                         Format: { "0" | "1" }

Hmm..

toggle parameter seems no good idea.
because if change default value in the future, boot parmeter becomes
an opposite meaning.

thus, we can't change default value even if we will be able to get
enough performance improvement in the future.

Thanks
