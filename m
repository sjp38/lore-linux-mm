Date: Fri, 21 Nov 2008 12:09:47 -0800 (PST)
From: Catalin CIONTU <cciontu@yahoo.com>
Reply-To: cciontu@yahoo.com
Subject: Re: linux memory mgmt system question
In-Reply-To: <Pine.LNX.4.64.0811211027210.26758@quilx.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Message-ID: <145268.78405.qm@web56504.mail.re3.yahoo.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <cl@linux-foundation.org>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hi,

Thanks for your reply. 

We need to provide these numbers for our customers, when we release reports of findings and assessments. The more accurate they are, with re to memory utilization, the better. They'll setup thresholds for their monitoring tools, based on our feedback.


Regards,
catalin.
--- On Fri, 11/21/08, Christoph Lameter <cl@linux-foundation.org> wrote:

> From: Christoph Lameter <cl@linux-foundation.org>
> Subject: Re: linux memory mgmt system question
> To: "Catalin CIONTU" <cciontu@yahoo.com>
> Cc: linux-mm@kvack.org
> Date: Friday, November 21, 2008, 6:29 PM
> The numbers returned by free are numbers that describe the
> state of the
> memory for the OS. The OS can increase the amount of free
> memory at
> any time by reclaiming memory from the disk cache,
> processes and other
> operating system structures.
> 
> Why do you need these numbers?


      

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
