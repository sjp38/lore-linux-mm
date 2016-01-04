From: Borislav Petkov <bp@alien8.de>
Subject: Re: [PATCH v6 2/4] x86: Cleanup and add a new exception class
Date: Mon, 4 Jan 2016 21:32:12 +0100
Message-ID: <20160104203212.GP22941@pd.tnic>
References: <cover.1451869360.git.tony.luck@intel.com>
 <18380d9d19d5165822d12532127de2fb7a8b8cc7.1451869360.git.tony.luck@intel.com>
 <20160104142213.GI22941@pd.tnic>
 <3908561D78D1C84285E8C5FCA982C28F39F9FF79@ORSMSX114.amr.corp.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <3908561D78D1C84285E8C5FCA982C28F39F9FF79@ORSMSX114.amr.corp.intel.com>
Sender: linux-kernel-owner@vger.kernel.org
To: "Luck, Tony" <tony.luck@intel.com>
Cc: Ingo Molnar <mingo@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Andy Lutomirski <luto@kernel.org>, "Williams, Dan J" <dan.j.williams@intel.com>, "elliott@hpe.com" <elliott@hpe.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-nvdimm@ml01.01.org" <linux-nvdimm@ml01.01.org>, "x86@kernel.org" <x86@kernel.org>
List-Id: linux-mm.kvack.org

On Mon, Jan 04, 2016 at 05:00:04PM +0000, Luck, Tony wrote:
> > So you're touching those again in patch 2. Why not add those defines to
> > patch 1 directly and diminish the churn?
> 
> To preserve authorship. Andy did patch 1 (the clever part). Patch 2 is just syntactic
> sugar on top of it.

That you can do in the way Ingo suggested.

-- 
Regards/Gruss,
    Boris.

ECO tip #101: Trim your mails when you reply.
